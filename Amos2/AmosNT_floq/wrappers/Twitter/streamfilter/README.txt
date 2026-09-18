1. Download and install Amos II
2. Set environment variable %AMOS_HOME% to home directory of Amos II
3. Run install.cmd in this folder
4. Run jsonstream.cmd
   
   e.g
   Initialize connection to twitter:
     set :c = init("http://stream.twitter.com/1/statuses/filter.json",
                   "username","password");

   Replace the username and password as your account of twitter. The
   username shoulb not be the mail address, your screen name will be
   accepted.

   Get jsonstream from twitter:
     set :s=trackstream(:c,"i",100); 
     count(in(:s));

   Repleace "i" as the keyword you want to query, e.g "a", then you
   can access Twitter Streaming API and get stream data including
   keyword "a".
    
   Build metadata of twitter stream:
     build_twittermetadata(:c);
   
   Get properties:
     getproperties("twitter");
     getsubproperties("user");
   
   Release connection:
     logout(:c);
  
   Available connections:
     available();  
   
   