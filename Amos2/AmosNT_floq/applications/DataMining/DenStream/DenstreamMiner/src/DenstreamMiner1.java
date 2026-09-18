/*
 * Author: Jiaowei Tang    Group: UDBL in IT Department, Uppsala University
 */

/*
 * Program description:
 * This program implements and modify the algorithm that is described in paper "Cao, F.,Ester, M., Qian, W., and Zhou, A. 2006. Density-based clustering over an
 * evolving data stream with noise. In Proceedings of the SIAM Conference on Data Mining". This algorithm show us how to make clusters on the data
 * stream with damped window. It is composed by two main parts, online and offline. In online, the data points will be clustered into a number of 
 * miro-clusters. At the same time, noise in the original data will be identified. Furthermore, the outlier micro-clusters have equal priority as potential 
 *core-micro-cluster to merge new data points. After that, bigger clusters will be formed by the miro-clusters by an algorithm similar to DBSCAN. 
 */

import java.io.*;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.StringTokenizer;
import java.util.ArrayList;
import java.util.regex.*;
import java.lang.Math;

import callin.*;
import callout.*;

public class DenstreamMiner1 {

	public DenstreamMiner1(){
    }

	/**************************************************************************************************************************************************
	 *                                              "start of Denstream algorithm"                                                                    *
	 * Below is the introduction of actual parameters in tuple used in this function.                                                                 *
	 * @param initialFile--data file used to initialize some p-micro-clusters                                                                         *
	 * @param dataFile--the data file which contain the data needed to be analyzed                                                                    *
	 * @param beta--one of parameters which determines the type of micro-cluster                                                                      *
	 * @param u--one of parameters which determines the type of micro-cluster. u*beta is used to measure if one micro-cluster is p-micro-cluster      *
	 * @param epsilon--a threshold for radius of micro-clusters                                                                                       *
	 * @param lamda--one parameter used in the fading function                                                                                        *
	 * @param dim--the dimension of the data                                                                                                          *
	 * @param timeInterval-- the time interval which is used to define how often the offline clustering is called                                     *
	 * @param initialOrNot--the value determines if there will be a initilization of stream. 1=initilization and 0=no initialization                  *
	 * @param overlapping--the value controls the max times of assigning same data point
	 **************************************************************************************************************************************************/

	//public void javaDenstream(String initialFile, String dataFile, double beta, double u, double epsilon, double lamda,int dim, double timeInterval, int initialOrNot, int overlapping){
      public void javaDenstream(CallContext cxt, Tuple tpl)throws AmosException{
		//load each parameter from the tuple
		String	initialFile=tpl.getStringElem(0);
		String	dataFile=tpl.getStringElem(1);
		double	beta=tpl.getDoubleElem(2);
		double	u=tpl.getDoubleElem(3);
		double	epsilon=tpl.getDoubleElem(4);
		double	lamda=tpl.getDoubleElem(5);
		int	dim=tpl.getIntElem(6);
		double	timeInterval=tpl.getDoubleElem(7);
		int	initialOrNot=tpl.getIntElem(8);
		int	overlapping=tpl.getIntElem(9);
		
	    /*create buffers for p-micro-clusters. Each element is a vector CF(CF1,CF2,(last update time,weight)). CF1, CF2 and (last update time,weight) all
		 * are vectors.
		 */
		ArrayList<ArrayList<ArrayList<Double>>> pMicroBuff = new ArrayList<ArrayList<ArrayList<Double>>>();
		
		/**************************************************************************************************************************************************
		 *                                              "initialization part of Denstream"                                                                *                                                                                                                                         *
		 *create a number of p-micro-clusters before online component                                                                                     *
		 **************************************************************************************************************************************************/
		int snapshot=0;//offline clustering time, not including the no cluster produced clustering
		if(initialOrNot==1){
			File inFile = new File(initialFile);
			try{
			    //Open the data file needs to be read
			    FileInputStream fileStream = new FileInputStream(inFile);
			    DataInputStream input = new DataInputStream(fileStream);
			    BufferedReader buffer = new BufferedReader(new InputStreamReader(input));
		
			    String stringLine;//store the line read from file
			    double [] datapoint=new double[dim+1];//data points will be stored into a vector
				
		
			    /*Read the data points from file line by line and each line is one point. The first value in line is the no of the point and others are
			     * coordinate values.
			     */
			    while ((stringLine = buffer.readLine()) != null)   {
		
			    	// read the values in line into array(datapoint) by regular expression
			    	if(stringLine.matches("\\s*(\\d+.\\d*\\s*)+\\s*")){ //ex: 1.00 2.00 3.00
						Pattern pat=Pattern.compile("(\\d+\\.\\d*)");
						Matcher match= pat.matcher(stringLine);
						int i=0;
		
						while(match.find()){
							datapoint[i]=Double.parseDouble(match.group());
							i++;
						}
			  	    }
		
				    //System.out.println("P-micro cluster buffer is empty or not:"+pMicroBuff.isEmpty());
		    		if(!pMicroBuff.isEmpty()){
		    		    //System.out.print("Try to mrege new point into p-micro cluster\n");
		                double minDistance=0;//the min-distance between new data point and one micro-cluster
				        int minIndex=-1;//index of one micro-cluster which has the min-distance with new data point
						//when a new point is come, find the nearest p-micro-cluster
						for(int i=0;i<pMicroBuff.size();i++){
							double tmpDistance=0;
		
							/*update feature vector of each micro-clusters and calculate the distances between clusters
							 *and point
							 */
							ArrayList<Double> tmpCF1=pMicroBuff.get(i).get(0);
							ArrayList<Double> tmpWeight=pMicroBuff.get(i).get(2);
		
							//update the CF1 and CF2 vector and calculate the distance
							for (int j=0;j<dim;j++){
								tmpDistance=tmpDistance +(tmpCF1.get(j)/tmpWeight.get(1)-datapoint[j+1])*(tmpCF1.get(j)/tmpWeight.get(1)-datapoint[j+1]);
							}
		
							//initializing and searching for one-micro-cluster having min-distance with coming data point
							if (i==0){
								minDistance=tmpDistance;
								minIndex=i;
							}
							else if(tmpDistance<minDistance){
								minDistance=tmpDistance;
								minIndex=i;
							}
						}
		
						//System.out.println("The smallest distance to one p-micro-clusteris:"+Math.sqrt(minDistance));
						if(Math.sqrt(minDistance)>epsilon){
		                    
							ArrayList<ArrayList<Double>> CF= new ArrayList<ArrayList<Double>>();//a feature vector for a cluster which is <CF1,CF2,WeightTime>
		
							/*define the three vectors for each feature vector. ArrayList WeightTime is <last update time, weight> for p-micro-cluster and for
							 *  o-micro-cluster it is  <last update time, cluster created time, weight>. ArrayList CF1 and CF2 are same as ones defined in paper
							 */
							ArrayList<Double> CF1=new ArrayList<Double>();
							ArrayList<Double> CF2=new ArrayList<Double>();
							ArrayList<Double> WeightTime=new ArrayList<Double>();
							//System.out.println("Create a new p-micro-cluster because of  mini-distance> epsilon");
							WeightTime.add(0,new Double(datapoint[0]));//created time
							WeightTime.add(1,new Double(1));//weight
		
							for(int i=1;i<dim+1;i++){
								CF1.add(new Double(datapoint[i]));
								CF2.add(new Double(datapoint[i]*datapoint[i]));
							}
		
							CF.add(CF1);
							CF.add(CF2);
							CF.add(WeightTime);
							pMicroBuff.add(CF);
		    		    }
						else{
		
							//System.out.println("Merge the new data point into nearest p-micro cluster because of  mini-distance<= epsilon");
							ArrayList<Double> tempCF1=pMicroBuff.get(minIndex).get(0);
							ArrayList<Double> tempCF2=pMicroBuff.get(minIndex).get(1);
							ArrayList<Double> tempWeight=pMicroBuff.get(minIndex).get(2);
							double updateTempWeight=tempWeight.get(1)+1;
							pMicroBuff.get(minIndex).get(2).set(1,new Double(updateTempWeight));						
							for (int j=0;j<dim;j++){
								   double updateCF1=tempCF1.get(j)+datapoint[j+1];
				    			   double updateCF2=tempCF2.get(j)+datapoint[j+1]*datapoint[j+1];
				    			   pMicroBuff.get(minIndex).get(0).set(j,new Double(updateCF1));
				    			   pMicroBuff.get(minIndex).get(1).set(j,new Double(updateCF2));
							}
						}
		    		}
					else{
						//System.out.println("Creating a new p-micro-cluster because there is no micro-cluster right now");
		                
						ArrayList<ArrayList<Double>> CF= new ArrayList<ArrayList<Double>>();//a feature vector for a cluster which is <CF1,CF2,WeightTime>
			
						/*define the three vectors for each feature vector. ArrayList WeightTime is <last update time, weight> for p-micro-cluster and for
						 *  o-micro-cluster it is  <last update time, cluster created time, weight>. ArrayList CF1 and CF2 are same as ones defined in paper
						 */
						ArrayList<Double> CF1=new ArrayList<Double>();
						ArrayList<Double> CF2=new ArrayList<Double>();
						ArrayList<Double> WeightTime=new ArrayList<Double>();
						
						//create a new o-micro-cluster by new point and insert it into pMicroBuff
						WeightTime.add(new Double(datapoint[0]));//created time
						WeightTime.add(new Double(1));//weight
		
						for(int i=1;i<dim+1;i++){
							CF1.add(new Double(datapoint[i]));
							CF2.add(new Double(datapoint[i]*datapoint[i]));
						}
						CF.add(CF1);
						CF.add(CF2);
						CF.add(WeightTime);
						pMicroBuff.add(CF);
					}// end of "if(!pMicroBuff.isEmpty())"
		
			    }// end of while
		
		    	//remove the cluster with very small weight(weight<u*beta)
				for(int i=0;i<pMicroBuff.size();i++){
					if (pMicroBuff.get(i).get(2).get(1)<u*beta){
						pMicroBuff.remove(i);
						i--;
					}
				}
				//System.out.println("After initialization, the number of p-micro-cluster is:"+pMicroBuff.size());
		
				//Close the input stream and buffer
			    fileStream.close();
			    buffer.close();
			    input.close();
			}catch (Exception e){//Catch exception if any
			    //System.err.println("Error: " + e.getMessage());
			}
		}
		

		/**************************************************************************************************************************************************
		 *                                         "online component of Denstream"                                                                        *
		 *                                                                                                                                                *
		 *  In this step, a number of p-micro-clusters and o-micro-clusters will be created. The evolution of micro-clusters is controlled by the fading  *
		 *  function and expressed by the evolution  of cluster feature vectors CF.                                                                       *
		 *  The data Stream is created by reading data files line by line. Data in each line is a data point and the first number is the time stamp for   *
		 *  that data point. The time is shown in double type. So, in file, the data point will be written in this way,"time x y z....".                  *
		 **************************************************************************************************************************************************/

		File daFile = new File(dataFile);
		try{

			/*create buffers for p-micro-clusters. Each element is a vector CF(CF1,CF2,(last update time,weight)). CF1, CF2
			 *and (last update time,weight) all are vectors.
			 */
            ArrayList<ArrayList<ArrayList<Double>>> oMicroBuff = new ArrayList<ArrayList<ArrayList<Double>>>();
            
            //arrayLists for purity of micro-clusters
//            ArrayList<ArrayList<ArrayList<Double>>> pPurity=new ArrayList<ArrayList<ArrayList<Double>>>();
//            ArrayList<ArrayList<ArrayList<Double>>> oPurity=new ArrayList<ArrayList<ArrayList<Double>>>();
//			
		    int counterTp=1;// the number of Tp

		    int counterInterval=1;//number of time intervals to do offline clustering

		    //Open the data file we want to read
		    FileInputStream fileStream = new FileInputStream(daFile);
		    DataInputStream input = new DataInputStream(fileStream);
		    BufferedReader buffer = new BufferedReader(new InputStreamReader(input));
            
		    //file to record the purity of mciro-clusters		
//			String outp="/Users/tangxuan/Master-thesis-CS/programming/work/data/synthetic data/purity_0.05_o.txt";
//		    File f=new File(outp);
//			FileOutputStream outPurity=new FileOutputStream(f);

		    String stringLine;//get the lines read from file
		    double [] datapoint=new double[dim+1];//each point will be read into array, and the first element is the time stamp


		    /*Read the data points from file line by line and each line is one point.
		     * The first value in line is time stamp of the point and others are coordinate values.
		     */
		    stringLine = buffer.readLine();
		    
		    double lastUpdateTime=-1;
		    do{
                
		    	// read the values in line into array(datapoint) by regular expression
//		    	if(stringLine.matches("\\s*(\\d+(\\.\\d+)?\\s+)+(\\d+(\\.\\d+)?)\\s*")){ //ex: 0.001 1.00 2.00 3.00
//		    		//System.out.println("here");
//					Pattern pat=Pattern.compile("(\\d+(\\.\\d+)?)");
//					Matcher match= pat.matcher(stringLine);
//					int i=0;
//					while(match.find()){
//						datapoint[i]=Double.parseDouble(match.group());
//						i++;
//					}
//		  	    }
		    	

		    	StringTokenizer st = new StringTokenizer(stringLine);
		    	int p=0;
				while(st.hasMoreTokens()){
					datapoint[p]=Double.parseDouble(st.nextToken());
					p++;
				}
				
                double [] minDistance= new double[overlapping];//the mini-distance array between new data point and micro-clusters
		        int [] minIndex=new int[overlapping];//index array of micro-clusters which have the mini-distance with new data point
		        int [] type=new int[overlapping];// the buffer type of micro-clusters which have the mini-distance with new data point. 1=PBuffer, 0=OBuffer
               
		        if(lastUpdateTime==-1){
                	lastUpdateTime=datapoint[0];
                }
		        
                //mount of fading from last update time to now
                double fad=Math.pow(2,-1*lamda*(datapoint[0]-lastUpdateTime));

		        //initializing the minDistance, index and type
		        for(int i=0;i<overlapping;i++){
			        	minDistance[i]=-1;
			        	minIndex[i]=-1;
			        	type[i]=-1;
			    }
               
                //System.out.println("Potential micro-cluster buffer is empty or not:"+pMicroBuff.isEmpty());
		        //find the nearest micro-cluster in potential micro-clusters
	    		if(!pMicroBuff.isEmpty()){
	    		    //System.out.print("P-micro-cluster Buffer: try to mrege new point into p-micro-cluster\n");
					
					
			        ArrayList<Integer> smallDisList=new ArrayList<Integer>();
			        
			        /*go through each feature vector of micro clusters and filter out the micro-clusters far from data point*/
					for(int i=0;i<pMicroBuff.size();i++){
						ArrayList<Double> tmpCF1=pMicroBuff.get(i).get(0);
						double tmpWeight=pMicroBuff.get(i).get(2).get(0);
                        int flag=0;
						for (int j=0;j<dim;j++){
							if (Math.abs(tmpCF1.get(j)/tmpWeight-datapoint[j+1])>epsilon){
								flag=0;
                                break;
							}
							else{
								flag=1;
							}
						}
						if(flag==1){
							smallDisList.add(i);
						}
						
					}//end of for
					
					//search for the nearest potential core-micro-clusters
					if(smallDisList.size()!=0){
	                    for(int i=0;i<smallDisList.size();i++){
	                    	double tmpDistance=0;
	                    	ArrayList<Double> tmpCF1=pMicroBuff.get(smallDisList.get(i)).get(0);
	                    	double updateWeight=pMicroBuff.get(smallDisList.get(i)).get(2).get(0);
	                    	for (int j=0;j<dim;j++){
	                    		double updateCF1=tmpCF1.get(j);
	                    		tmpDistance=tmpDistance +(updateCF1/updateWeight-datapoint[j+1])*(updateCF1/updateWeight-datapoint[j+1]);
	                    	}
							int tmpI=smallDisList.get(i);
							int tmpType=1;
							for(int j=0;j<overlapping;j++){
								if(minDistance[j]<0){
									minIndex[j]=tmpI;
									minDistance[j]=tmpDistance;
									type[j]=tmpType;
									break;
								}
								else{
									if(tmpDistance<=minDistance[j]){
										int tempI=minIndex[j];
										double tempDistance=minDistance[j];
										int tempType=type[j];
										minIndex[j]=tmpI;
										minDistance[j]=tmpDistance;
										type[j]=tmpType;
										tmpI=tempI;
										tmpType=tempType;
										tmpDistance=tempDistance;
									}
								}
							}//end of for
	                    }
					}

	    		}// end of "if(!pMicroBuff.isEmpty())"

	    		//find the nearest micro-cluster in o-micro-clusters
				if(!oMicroBuff.isEmpty()){
					//System.out.print("O-micro-cluster Buffer:try to merge new point into one o-micro-cluster \n");
					
			        ArrayList<Integer> smallDisList=new ArrayList<Integer>();
			        
			        /*go through each feature vector of micro clusters and filter out the micro-clusters far from data point*/
					for(int i=0;i<oMicroBuff.size();i++){
 						ArrayList<Double> tmpCF1=oMicroBuff.get(i).get(0);
						double tmpWeight=oMicroBuff.get(i).get(2).get(1);
 						int flag=0;
						for (int j=0;j<dim;j++){

							if (Math.abs(tmpCF1.get(j)/tmpWeight-datapoint[j+1])>epsilon){
								flag=0;
                                break;
							}
							else{
								flag=1;
							}
						}
						if(flag==1){
							smallDisList.add(i);
						}
					}
					
					for(int i=0;i<smallDisList.size();i++){
                    	double tmpDistance=0;
                    	ArrayList<Double> tmpCF1=oMicroBuff.get(smallDisList.get(i)).get(0);
                    	double updateWeight=oMicroBuff.get(smallDisList.get(i)).get(2).get(1);
                    	for (int j=0;j<dim;j++){
                    		double updateCF1=tmpCF1.get(j);
                    		tmpDistance=tmpDistance +(updateCF1/updateWeight-datapoint[j+1])*(updateCF1/updateWeight-datapoint[j+1]);
                    	}
						//search for micro-cluster wirh the miniDistance 
						int tmpI=smallDisList.get(i);
						int tmpType=0;
						for(int j=0;j<overlapping;j++){
							if(minDistance[j]<0){
								minIndex[j]=tmpI;
								minDistance[j]=tmpDistance;
								type[j]=tmpType;
								break;
							}
							else{
								if(tmpDistance<=minDistance[j]){
									int tempI=minIndex[j];
									double tempDistance=minDistance[j];
									int tempType=type[j];
									minIndex[j]=tmpI;
									minDistance[j]=tmpDistance;
									type[j]=tmpType;
									tmpI=tempI;
									tmpDistance=tempDistance;
									tmpType=tempType;
								}
							}
						}//end of for

					}    //end of for
						
					if(smallDisList.size()==0 && minDistance[0]<0){
						//System.out.print("O-micro-cluster Buffer:creating a new o-micro cluster when buffer isn't empty\n");
						ArrayList<ArrayList<Double>> CF= new ArrayList<ArrayList<Double>>(3);

						/*define the three vectors for each feature vector. ArrayList WeightTime is <last update time, weight> for p-micro-cluster
						 * and for o-micro-cluster it is  <last update time, cluster created time, weight>. ArrayList CF1 and CF2 are same as ones
						 * defined in paper.
						 */
						ArrayList<Double> CF1=new ArrayList<Double>(dim);
						ArrayList<Double> CF2=new ArrayList<Double>(dim);
						ArrayList<Double> WeightTime=new ArrayList<Double>(2);
						
						//create a new o-micro-cluster by new point and insert it into oMicroBuff
						//WeightTime.add(0,new Double(datapoint[0]));//last update time
						WeightTime.add(0,new Double(datapoint[0]));//created time
						WeightTime.add(1,new Double(1/fad));//weight

						for(int i=1;i<dim+1;i++){
							CF1.add(new Double(datapoint[i]/fad));
							CF2.add(new Double(datapoint[i]*datapoint[i]/fad));

						}

						CF.add(CF1);
						CF.add(CF2);
						CF.add(WeightTime);
						oMicroBuff.add(CF);
						
						//create new purity record for new data point
//						ArrayList<Double> tmpV=new ArrayList<Double>();
//						ArrayList<ArrayList<Double>> tempV=new ArrayList<ArrayList<Double>>();
//						tmpV.add(datapoint[dim+1]);
//						tmpV.add(new Double(1));
//						tempV.add(tmpV);
//						oPurity.add(tempV);
					}
				}
				else{
					//System.out.print("O-micro-cluster Buffer:create a new o-micro cluster when buffer is empty\n");
                    //a feature vector for a cluster which is <CF1,CF2,WeightTime>
					ArrayList<ArrayList<Double>> CF= new ArrayList<ArrayList<Double>>(3);

					/*define the three vectors for each feature vector. ArrayList WeightTime is <last update time, weight> for p-micro-cluster
					 * and for o-micro-cluster it is  <last update time, cluster created time, weight>. ArrayList CF1 and CF2 are same as ones
					 * defined in paper.
					 */
					ArrayList<Double> CF1=new ArrayList<Double>(dim);
					ArrayList<Double> CF2=new ArrayList<Double>(dim);
					ArrayList<Double> WeightTime=new ArrayList<Double>(2);
					
					//create a new o-micro-cluster by new point and insert it into oMicroBuff
					WeightTime.add(0,new Double(datapoint[0]));//created time
					WeightTime.add(1,new Double(1/fad));//weight

					for(int i=1;i<dim+1;i++){
						CF1.add(new Double(datapoint[i]/fad));
						CF2.add(new Double(datapoint[i]*datapoint[i]/fad));

					}

					CF.add(CF1);
					CF.add(CF2);
					CF.add(WeightTime);
					oMicroBuff.add(CF);
					
					//create new purity record for new data point
//					ArrayList<Double> tmpV=new ArrayList<Double>();
//					ArrayList<ArrayList<Double>> tempV=new ArrayList<ArrayList<Double>>();
//					tmpV.add(datapoint[dim+1]);
//					tmpV.add(new Double(1));
//					tempV.add(tmpV);
//					oPurity.add(tempV);
				}
				
				int merge=0;//the times of data points merged.
				//merge the new datapoint into the nearest micro-clusters
				for(int i=0;i<overlapping;i++){
					
					if(minDistance[i]<0) break;
					
					//System.out.println("O-micro-cluster Buffer: the smallest distance to one o-micro-cluster is:"+Math.sqrt(minDistance));
					if(minDistance[i]>epsilon*epsilon){
						//System.out.print("O-micro-cluster Buffer:creating a new o-micro cluster when buffer isn't empty\n");
						
                        //a feature vector for a cluster which is <CF1,CF2,WeightTime>
						if(merge==0){
							//System.out.println("len="+len);
							ArrayList<ArrayList<Double>> CF= new ArrayList<ArrayList<Double>>(3);

							/*define the three vectors for each feature vector. ArrayList WeightTime is <last update time, weight> for p-micro-cluster
							 * and for o-micro-cluster it is  <last update time, cluster created time, weight>. ArrayList CF1 and CF2 are same as ones
							 * defined in paper.
							 */
							ArrayList<Double> CF1=new ArrayList<Double>(dim);
							ArrayList<Double> CF2=new ArrayList<Double>(dim);
							ArrayList<Double> WeightTime=new ArrayList<Double>(2);
							
							//create a new o-micro-cluster by new point and insert it into oMicroBuff
							WeightTime.add(0,new Double(datapoint[0]));//created time
							WeightTime.add(1,new Double(1/fad));//weight

							for(int j=1;j<dim+1;j++){
								CF1.add(new Double(datapoint[j]/fad));
								CF2.add(new Double(datapoint[j]*datapoint[j]/fad));
							}

							CF.add(CF1);
							CF.add(CF2);
							CF.add(WeightTime);
							oMicroBuff.add(CF);
							
							//create new purity record for new data point
//							ArrayList<Double> tmpV=new ArrayList<Double>();
//							ArrayList<ArrayList<Double>> tempV=new ArrayList<ArrayList<Double>>();
//							tmpV.add(datapoint[dim+1]);
//							tmpV.add(new Double(1));
//							tempV.add(tmpV);
//							oPurity.add(tempV);
							
							break;
						}
		            }
					else{
						//System.out.println("O-micro-cluster Buffer:merge the new point to the nearest o-micro-cluster");
						if(type[i]==0){
							//System.out.println("O-micro-cluster Buffer:merge the new point to the nearest o-micro-cluster");
							//merge the new point to the nearest existing o-micro-cluster
							ArrayList<Double> tempCF1=oMicroBuff.get(minIndex[i]).get(0);
							ArrayList<Double> tempCF2=oMicroBuff.get(minIndex[i]).get(1);
							ArrayList<Double> tempWeight=oMicroBuff.get(minIndex[i]).get(2);
							double updateTempWeight=tempWeight.get(1)+1/fad;
							tempWeight.set(1,new Double(updateTempWeight));//update the weight
							for (int j=0;j<dim;j++){
								   double updateCF1=tempCF1.get(j)+datapoint[j+1]/fad;
				    			   double updateCF2=tempCF2.get(j)+datapoint[j+1]*datapoint[j+1]/fad;
				    			   tempCF1.set(j,new Double(updateCF1));
				    			   tempCF2.set(j,new Double(updateCF2));
							}
							
							//update the purity of the outlier micro-cluster
//							int flag=0;
//							//System.out.println(oMicroBuff.size() +" "+minIndex);
//							for(int j=0; j<oPurity.get(minIndex[i]).size();j++){
//								if(oPurity.get(minIndex[i]).get(j).get(0)==datapoint[dim+1]){
//									oPurity.get(minIndex[i]).get(j).set(1,oPurity.get(minIndex[i]).get(j).get(1)+1);
//									flag=1;
//									break;
//								}
//							}
//							if (flag==0){
//								ArrayList<Double> tmpV=new ArrayList<Double>();
//								tmpV.add(datapoint[dim+1]);
//								tmpV.add(new Double(1));
//								oPurity.get(minIndex[i]).add(tmpV);
//							}
						}
						else{
							//merge the new point to the nearest existed p-micro-cluster
							//System.out.println("len="+len);
							ArrayList<Double> tempCF1=pMicroBuff.get(minIndex[i]).get(0);
							ArrayList<Double> tempCF2=pMicroBuff.get(minIndex[i]).get(1);
							ArrayList<Double> tempWeight=pMicroBuff.get(minIndex[i]).get(2);
							double updateTempWeight=tempWeight.get(0)+1/fad;
							tempWeight.set(0,new Double(updateTempWeight));
							for (int j=0;j<dim;j++){
								   double updateCF1=tempCF1.get(j)+datapoint[j+1]/fad;
				    			   double updateCF2=tempCF2.get(j)+datapoint[j+1]*datapoint[j+1]/fad;
				    			   tempCF1.set(j,new Double(updateCF1));
				    			   tempCF2.set(j,new Double(updateCF2));
							}
							
							//update the weight of potential core-micro-cluster
//							int flag=0;
//							for(int j=0; j<pPurity.get(minIndex[i]).size();j++){
//								if(pPurity.get(minIndex[i]).get(j).get(0)==datapoint[dim+1]){
//									pPurity.get(minIndex[i]).get(j).set(1,pPurity.get(minIndex[i]).get(j).get(1)+1);
//									flag=1;
//									break;
//								}
//							}
//							if (flag==0){
//								ArrayList<Double> tmpV=new ArrayList<Double>();
//								tmpV.add(datapoint[dim+1]);
//								tmpV.add(new Double(1));
//								pPurity.get(minIndex[i]).add(tmpV);
//							}
						}
						merge=merge+1;
						//System.out.println("merge="+merge);
					}//end of if-else
				}//end of for
				
				
				//System.out.println("Values of parameters: Tp="+Tp+" current time="+datapoint[0]+" counterTp="+counterTp+" counterInterval="+counterInterval);
		    	//System.out.println("*************************New datapoint has been megerd*******************************");

		    	/*
		    	 * According to a special time interval, check the clusters in outlier buffer, remove the one can
		    	 * not be a potential core micro-cluster from buffer and move the one which is already a potential
		    	 * core micro-cluster to potential core micro-cluster buffer.  Also, check the clusters in
		    	 * potential core micro-cluster buffer and move the clusters with low weight which can not be a
		    	 * potential core micro-cluster right now into outlier buffer.
		    	 */
			    
				//vector with indexes of clusters which will be deleted from p-micro-clusters buffer
			    ArrayList<Integer> delCluster=new ArrayList<Integer>();

			    //vector with indexes of clusters which will be moved from o-micro-clusters buffer to p-micro-clusters buffer
			    ArrayList<Integer> oToPCluster=new ArrayList<Integer>();

			    //vector with indexes of clusters which will be moved from p-micro-clusters buffer to o-micro-clusters buffer
			    ArrayList<Integer> pToOCluster=new ArrayList<Integer>();

			    //After a time period of Tp, checking all the micro-clusters and decide which clusters will be moved or deleted
			    Double Tp=1/lamda*Math.log(beta*u/(beta*u-1))/Math.log(2);
			   // System.out.println(counterInterval*timeInterval+" "+datapoint[0]);
		    	if (datapoint[0]>=Tp*counterTp || datapoint[0]>=counterInterval*timeInterval){
		    		//System.out.println("The size of o-micro-cluster before conversion:"+oMicroBuff);

					if(datapoint[0]>=Tp*counterTp)
		    		     counterTp++;

					//find out the p-micro-clusters with weight<beta*u in p-micro-clusters buffer
					if(!pMicroBuff.isEmpty()){
						for(int i=0;i<pMicroBuff.size();i++){
							ArrayList<Double> tmpCF1=pMicroBuff.get(i).get(0);
							ArrayList<Double> tmpCF2=pMicroBuff.get(i).get(1);
							ArrayList<Double> tmpWeight=pMicroBuff.get(i).get(2);

							//update the weight
							double updateWeight=tmpWeight.get(0)*fad;
							tmpWeight.set(0,new Double(updateWeight));

							//update the CF1 and CF2 vector
							for (int j=0;j<dim;j++){
								double updateCF1=tmpCF1.get(j)*fad;
								double updateCF2=tmpCF2.get(j)*fad;
								pMicroBuff.get(i).get(0).set(j,new Double(updateCF1));
								pMicroBuff.get(i).get(1).set(j,new Double(updateCF2));
							}

							//add the index of low weight cluster into a vector
							if (updateWeight<beta*u){
								pToOCluster.add(new Integer(i));
							}
						}

		    		}//if(!pMicroBuff.isEmpty())

		    		//find out the o-micro-clusters with weight>=beta*u or weight<"specific value" in o-micro-clusters buffer
		    		if(!oMicroBuff.isEmpty()){
						for(int i=0;i<oMicroBuff.size();i++){

							ArrayList<Double> tmpCF1=oMicroBuff.get(i).get(0);
							ArrayList<Double> tmpCF2=oMicroBuff.get(i).get(1);
							ArrayList<Double> tmpWeight=oMicroBuff.get(i).get(2);
							//double weight=tmpWeight.get(2);
							double createTime=tmpWeight.get(0);

							//update weight
							double updateWeight=tmpWeight.get(1)*fad;
							tmpWeight.set(1,new Double(updateWeight));
							
							//update the CF1 and CF2 vector
							for (int j=0;j<dim;j++){
								double updateCF1=tmpCF1.get(j)*fad;
								double updateCF2=tmpCF2.get(j)*fad;
								tmpCF1.set(j,new Double(updateCF1));
								tmpCF2.set(j,new Double(updateCF2));

							}

							//add the index of high weight(>Beta*u) cluster into  oToPCluster vector
							if (updateWeight>=beta*u)
								oToPCluster.add(new Integer(i));

							//add the index of very low weight(< limit) cluster into delCluster vector
							else if(updateWeight<(Math.pow(2, -1*lamda*(datapoint[0]-createTime+Tp))-1)/(Math.pow(2, -1*lamda*Tp)-1))
								delCluster.add(new Integer(i));
						}
		    		}//end of "if(!oMicroBuff.isEmpty())"
		    		//System.out.println("The size of o-micro-cluster before conversion:"+oMicroBuff.size());
		    	    //System.out.println("The size of p-micro-cluster before conversion:"+pMicroBuff.size());
//		    	    System.out.println("The size of o-micro-cluster before conversion:"+oPurity.size());
//		    	    System.out.println("The size of p-micro-cluster before conversion:"+pPurity.size());
		        	//System.out.println("Before conversion: The size of conversion from o-micro-cluster to p-micro-cluster:"+oToPCluster.size());
		        	//System.out.println("Before conversion: The size of deletion in o-micro-clusters:"+delCluster.size());
			    	//System.out.println("Before conversion: The size of conversion from p-micro-cluster to o-micro-cluster:"+pToOCluster.size());

		    		//move o-micro-clusters with high weight into p-micro-clusters buffer
		    		for(int i=0;i<oToPCluster.size();i++){
		    			ArrayList<ArrayList<Double>> tmpOCluster=oMicroBuff.get(oToPCluster.get(i));


		    			tmpOCluster.get(2).remove(0);//remove the created time
		    			pMicroBuff.add(tmpOCluster);
						
//						pPurity.add(oPurity.get(oToPCluster.get(i)));
		    		}

		    		//combine the indexes of o-micro-clusters which will be removed from o-micro-cluster buffer
		    		for(int i=0;i<delCluster.size();i++){
		    			oToPCluster.add(delCluster.get(i));
		    		}
		    		delCluster.clear();
		    		Collections.sort(oToPCluster);//sort the indexes into increase order

		    		//move p-micro-clusters with low weight into o-micro-clusters buffer
		    		for(int i=0;i<pToOCluster.size();i++){
		    			ArrayList<ArrayList<Double>> tmpPCluster=pMicroBuff.get(pToOCluster.get(i)-i);
		    			tmpPCluster.get(2).add(0,new Double(datapoint[0]));//add the created time
		    			oMicroBuff.add(tmpPCluster);
						pMicroBuff.remove(pToOCluster.get(i)-i);
						
//						oPurity.add(pPurity.get(pToOCluster.get(i)-i));
//						pPurity.remove(pToOCluster.get(i)-i);
		    		}
		    		pToOCluster.clear();



		    		//remove o-micro-clusters from o-micro-clusters buffer which are deleted from buffer forever or moved to p-micro-clusters buffer
		    		for(int i=0;i<oToPCluster.size();i++){
						oMicroBuff.remove(oToPCluster.get(i)-i);
//						oPurity.remove(oToPCluster.get(i)-i);
		    		}
		    		oToPCluster.clear();

		    		////System.out.println("After:"+oMicroBuff);
		    		//System.out.println("After conversion: The size of conversion from o-micro-cluster to p-micro-cluster:"+oToPCluster.size());
		        	//System.out.println("After conversion: The size of deletion:"+delCluster.size());
			    	//System.out.println("After conversion: The size of conversion from p-micro-cluster to o-micro-cluster:"+pToOCluster.size());
			    	//System.out.println("The size of o-micro-cluster after conversion:"+oMicroBuff.size());
		    	    //System.out.println("The size of p-micro-cluster after conversion:"+pMicroBuff.size());
		    		 //System.out.println("The size of o-micro-cluster after conversion:"+oPurity.size());
			    	  //  System.out.println("The size of p-micro-cluster after conversion:"+pPurity.size());
//			    	for(int i=0;i<pMicroBuff.size();i++){
//			    		System.out.println(i+"     "+pMicroBuff.get(i));
//			    	}
		    		lastUpdateTime=datapoint[0];
		    	}//end of "if (datapoint[0]>Tp*counterTp)"
                
		    	stringLine=buffer.readLine();


		    	/*
		    	 * call the offline clustering if the defined time interval is arrived.  What we really care is
				 * just the p-micro-clusters.
		    	 */
		    	if (datapoint[0]>=counterInterval*timeInterval || datapoint[0]<counterInterval*timeInterval && stringLine==null){
		    		if(datapoint[0]<counterInterval*timeInterval && stringLine==null){
		    			//System.out.println("Read file finished and convert o-micro-cluster with hight weight to o-micro-cluster");

		                if(!pMicroBuff.isEmpty()){
			    			for(int i=0;i<pMicroBuff.size();i++){
			    				if(pMicroBuff.get(i).get(2).get(0)<u*beta){
			    					pMicroBuff.remove(i);
//			    					pPurity.remove(i);
			    				}
			    			}
			    		}
			    		if(!oMicroBuff.isEmpty()){
			    			for(int i=0;i<oMicroBuff.size();i++){
			    				if(oMicroBuff.get(i).get(2).get(1)>=u*beta){
			    					oMicroBuff.get(i).get(2).remove(0);
			    					pMicroBuff.add(oMicroBuff.get(i));
//			    					pPurity.add(oPurity.get(i));
			    				}
			    			}
			    		}
		    		}
		    		
		    		/**************************************************************************************************************************************************
		    		 *                             "offline component of Denstream"                                                                                   *                                                                                                      *
		    		 *                                                                                                                                                *
		    		 * This method will be used as a foreign function for AmosII and the final clusters be transfered and stored into database.                       *
		    		 **************************************************************************************************************************************************/
					
		    		//System.out.println("**************************Start offline processing*********************************");
		        	ArrayList<Integer> coreCluster=new ArrayList<Integer>();//collection of indexes of core-micro-clusters
		        	ArrayList<ArrayList<ArrayList<Double>>> microClusters= new ArrayList<ArrayList<ArrayList<Double>>>();// A collection of centers and radius of p-micro-clusters
		            //System.out.println("The number of p-micro-cluster is:"+pMicroBuff.size());

		    		//create a collection about centers and radius of micro clusters
		    		for(int i=0;i<pMicroBuff.size();i++){
		    			double rCore=0;//radius of micro core cluster
		    		    double tmpCoreCF1=0;
		    		    double tmpCoreCF2=0;
		    		    ArrayList<ArrayList<Double>> temp1=new ArrayList<ArrayList<Double>>();

		    		    //calculate the radius of micro core cluster
		    			for(int k=0;k<dim;k++){
		    				tmpCoreCF1=tmpCoreCF1+Math.pow(pMicroBuff.get(i).get(0).get(k),2);
		    				tmpCoreCF2=tmpCoreCF2+pMicroBuff.get(i).get(1).get(k);
		    			}
		    			rCore=Math.sqrt((tmpCoreCF2/pMicroBuff.get(i).get(2).get(0)-tmpCoreCF1/Math.pow(pMicroBuff.get(i).get(2).get(0),2))/dim);

		    			////System.out.println("the weight of each micro-core cluster is:"+pMicroBuff.get(i).get(2).get(1));
		    			////System.out.println("the radius of each micro-core cluster is:"+rCore);
		    			ArrayList<Double> temp2=new ArrayList<Double>();
		    			temp2.add(rCore);
		    			ArrayList<Double> temp3=new ArrayList<Double>();
		    			for(int k=0;k<dim;k++){
		    			    temp3.add(pMicroBuff.get(i).get(0).get(k)/pMicroBuff.get(i).get(2).get(0));
		    			}
		    			temp1.add(temp3);
		    			temp1.add(temp2);
		    			microClusters.add(temp1);
		    		}//end of for

		    		//find out indxes of the core-micro-clusters in the p-micro-cluster buffer
		    		for(int i=0; i<microClusters.size();i++){
		    			double weight=pMicroBuff.get(i).get(2).get(0);
		    			if (weight>=u){
		    				coreCluster.add(new Integer(i));
		    			}
		    		}

		        	//directly density reachable core micro clusters in the current data(index of micro cluster)
		        	ArrayList<ArrayList<Integer>> drrClusters=new ArrayList<ArrayList<Integer>>();


		        	//System.out.println("The number of core-micro-cluster in offline is:"+coreCluster.size());
		    		//System.out.println("The number of p-micro-cluster in offline is:"+microClusters.size());

		    		//find out the directly density-reachable, there will be some overlapping  between density-reachable micro clusters of each core-micro cluster
		    		for(int i=0; i<coreCluster.size();i++){
		    			ArrayList<Integer> tmpDdr=new ArrayList<Integer>();//directly reachable p-micro-clusters for each core-micro-cluster

		    			//calculate the radius of directly reachable p-micro-cluster
		    			for(int j=0; j<microClusters.size();j++){
		    			    double distance=0;
		    			    for(int k=0;k<dim;k++){
		    			    	distance=distance+Math.pow((microClusters.get(coreCluster.get(i)).get(0).get(k)
		    												-microClusters.get(j).get(0).get(k)),2);
		    			    }
		    				//if(Math.sqrt(distance)<=2*epsilon && Math.sqrt(distance)<= microClusters.get(coreCluster.get(i)).get(1).get(0)+microClusters.get(j).get(1).get(0)){
		    			    if(Math.sqrt(distance)<=2*epsilon){
		    				    tmpDdr.add(new Integer(j));
		    				}
		    			}
		    			drrClusters.add(tmpDdr);
		    		}
		    		//System.out.println("The number of drr-cluster is:"+drrClusters.size());

		    		//not really do density reachable work, and cluster on core-miro-clusters
		    		ArrayList<ArrayList<Integer>> clusteringOfcores= new ArrayList<ArrayList<Integer>> ();
		    		ArrayList<Integer>tempCoreCluster=(ArrayList<Integer>)coreCluster.clone();
		    		while(!tempCoreCluster.isEmpty()){
		    			ArrayList<Integer> tmp=new ArrayList<Integer>();
		    			tmp.add(tempCoreCluster.get(0));
		    			clusteringOfcores.add(tmp);
		    			tempCoreCluster.remove(0);
		    			if(!tempCoreCluster.isEmpty()){
		    				for(int j=0;j<clusteringOfcores.size();j++){
		    					for(int m=0;m<clusteringOfcores.get(j).size();m++){
		    						for(int n=0; n<tempCoreCluster.size();n++){
		    							double distance=0;
		    							for(int k=0;k<dim;k++){
		    								distance=distance+Math.pow(microClusters.get(clusteringOfcores.get(j).get(m)).get(0).get(k)
		    														   -microClusters.get(tempCoreCluster.get(n)).get(0).get(k),2);
		    							}
		    							//if(Math.sqrt(distance)<=2*epsilon && Math.sqrt(distance)<= microClusters.get(clusteringOfcores.get(j).get(m)).get(1).get(0)+microClusters.get(tempCoreCluster.get(0)).get(1).get(0)){
		    							if(Math.sqrt(distance)<=2*epsilon ){
		    								clusteringOfcores.get(j).add(tempCoreCluster.get(n));
		    								tempCoreCluster.remove(n);
		    								m--;//start over again
		    								break;
		    							}
		    						}
		    						if(tempCoreCluster.isEmpty())
		    							break;
		    					}
		    					if(tempCoreCluster.isEmpty())
		    						break;
		    				}
		    			}
		    		}
		    		//System.out.println("The number of clusters in core-micro-cluster is:"+clusteringOfcores.size());

		    		//combine the  p-micro-core clusters belonging to same cluster according to the clustering of  core-miro-cluster
		    		ArrayList<ArrayList<Integer>>collectionOfClusters=new ArrayList<ArrayList<Integer>>();
		    		for(int j=0;j<clusteringOfcores.size();j++){
		    			ArrayList<Integer> temp=new ArrayList<Integer>();

		    			for(int m=0; m<clusteringOfcores.get(j).size();m++){
		    				temp.addAll(drrClusters.get((coreCluster.indexOf(clusteringOfcores.get(j).get(m)))));
		    			}
		    			collectionOfClusters.add(temp);
		    		}

		    		//remove the repetition in each cluster
		    		for(int j=0;j<collectionOfClusters.size();j++){
		    		    ArrayList<Integer> newVect = new ArrayList<Integer>(new LinkedHashSet(collectionOfClusters.get(j)));
		    		    collectionOfClusters.set(j, newVect);
		    		}
                    
                    //calculate the purity for each macro-cluster
		    		//System.out.println("pPurity:"+pPurity);
		    		//System.out.println("collectionOfClusters"+collectionOfClusters);
//		    		ArrayList<ArrayList<ArrayList<Double>>> clusterPurity=new ArrayList<ArrayList<ArrayList<Double>>>(); 
//		    		for(int j=0;j<collectionOfClusters.size();j++){
//		    			ArrayList<ArrayList<Double>> tmp=new ArrayList<ArrayList<Double>>();
//		    			tmp=pPurity.get(collectionOfClusters.get(j).get(0));
//	    				for(int k=1;k<collectionOfClusters.get(j).size();k++){
//	    					for(int m=0;m<pPurity.get(collectionOfClusters.get(j).get(k)).size();m++){
//	    						int flag=0;
//	    						for(int n=0;n<tmp.size();n++){
//
//	    							if(pPurity.get(collectionOfClusters.get(j).get(k)).get(m).get(0).intValue()==tmp.get(n).get(0).intValue()){
//	    								//System.out.println(pPurity.get(collectionOfClusters.get(j).get(k)).get(m).get(0));
//	    								//System.out.println(tmp.get(n).get(0));
//	    								double com=pPurity.get(collectionOfClusters.get(j).get(k)).get(m).get(1)+tmp.get(n).get(1);
//	    								tmp.get(n).set(1,new Double(com));
//	    								flag=1;
//	    								break;
//	    							}
//	    						}
//	    						if(flag==0){
//	    							tmp.add(pPurity.get(collectionOfClusters.get(j).get(k)).get(m));
//	    						}
//	    					}
//	    				}
//	    				clusterPurity.add(tmp);
//		    		}
//		    		//System.out.println("clusterPurity"+clusterPurity);
//		    		double purity=0;
//		    		double size=clusterPurity.size();
//		    		for(int i=0;i<clusterPurity.size();i++){
//		    			double max=0;
//		    			double sum=0;
//		    			for(int j=0;j<clusterPurity.get(i).size();j++){
//		    				if(clusterPurity.get(i).get(j).get(1)>max){
//		    					max=clusterPurity.get(i).get(j).get(1);
//		    				}
//		    				sum=sum+clusterPurity.get(i).get(j).get(1);
//		    			}
//		    			//System.out.println("sum="+sum);
//		    			if(sum!=0){
//		    			   purity=purity+max/sum;
//		    			}
//		    			else{
//		    				size--;
//		    			}
//		    		}
//		    		if(size!=0){
//		    		   purity=purity/size;
//		    		}
//		    		String tmpStr=new Double(datapoint[0]).toString()+" ";
//		    		outPurity.write(tmpStr.getBytes());
//		    		//out1.write("sdssdvdsvdfsdddds");
//		    		tmpStr=new Double(purity).toString()+"\n";
//		    		outPurity.write(tmpStr.getBytes());
//		    		//System.out.println("purity="+purity);
//		    		
//		    		//clear the pPurity and oPurity
//		    		for(int i=0;i<pPurity.size();i++){
//    				    pPurity.get(i).clear();
//    				    ArrayList<Double> tmp=new ArrayList<Double>();
//    				    tmp.add(new Double(0));
//    				    tmp.add(new Double(0));
//    					pPurity.get(i).add(tmp);
//		    		}
//		    		
//		    		for(int i=0;i<oPurity.size();i++){
//		    			oPurity.get(i).clear();
//    				    ArrayList<Double> tmp=new ArrayList<Double>();
//    				    tmp.add(new Double(0));
//    				    tmp.add(new Double(0));
//    					oPurity.get(i).add(tmp);
//		    		}
		    		
		    		//send the centers of p-micro-clusters and their cluster label to Amos II
		    	    try {
		    			for(int j=0;j<collectionOfClusters.size();j++){
		    				for(int k=0;k<collectionOfClusters.get(j).size();k++){
								tpl.setElem(10,snapshot);
								tpl.setElem(11,datapoint[0]);//input produced time of micro cluster into tuple
		    					tpl.setElem(12,j);//input the cluster label of micro cluster into tuple
								
		    					Tuple pos=new Tuple(dim);
		    					for(int m=0;m<dim;m++){
		    						pos.setElem(m,microClusters.get(collectionOfClusters.get(j).get(k)).get(0).get(m));
		    					}
		    				  
								Tuple microCluster=new Tuple(2);
								microCluster.setElem(0,pos);//input the space position of micro cluster into tuple
								microCluster.setElem(1,microClusters.get(collectionOfClusters.get(j).get(k)).get(1).get(0));
								tpl.setElem(13, microCluster);
		    					cxt.emit(tpl);
		    				}
		    			}
						if(collectionOfClusters.size()>0){
						    snapshot++;
						}
		    	    } catch (AmosException e) {
		    			e.printStackTrace();
		    	    }
		    		//System.out.println("**************************End offline processing*********************************");
					counterInterval++;
		    	}//end of "if (datapoint[0]>counterInterval*timeInterval)"
		   }while (stringLine!=null);//end of while

           fileStream.close();
           buffer.close();
           input.close();

	       }catch (Exception e){//Catch exception if any
	    	   e.printStackTrace();
	       }
	 }
}
