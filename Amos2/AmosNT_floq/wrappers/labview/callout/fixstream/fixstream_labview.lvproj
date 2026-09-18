<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="10008000">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="fixstream_labview_close.vi" Type="VI" URL="../fixstream_labview_close.vi"/>
		<Item Name="fixstream_labview_connect.vi" Type="VI" URL="../fixstream_labview_connect.vi"/>
		<Item Name="fixstream_labview_receive.vi" Type="VI" URL="../fixstream_labview_receive.vi"/>
		<Item Name="Dependencies" Type="Dependencies"/>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="fixstream_labview" Type="DLL">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{F81114EB-42F3-4996-B31E-B54042E552D8}</Property>
				<Property Name="App_INI_GUID" Type="Str">{5DB41AF2-FD42-4EF9-B0CA-6B1D0909BD59}</Property>
				<Property Name="App_winsec.description" Type="Str">http://www.FALSE.com</Property>
				<Property Name="Bld_buildSpecName" Type="Str">fixstream_labview</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">..</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Destination[0].destName" Type="Str">fixstream_labview.dll</Property>
				<Property Name="Destination[0].path" Type="Path">../NI_AB_PROJECTNAME.dll</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../fixstream/data</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="Dll_delayOSMsg" Type="Bool">true</Property>
				<Property Name="Dll_headerGUID" Type="Str">{393E6732-F1B3-448D-95FC-C72635AD200B}</Property>
				<Property Name="Dll_libGUID" Type="Str">{E8F04580-9933-4E0B-8C22-5E747815B395}</Property>
				<Property Name="Source[0].itemID" Type="Str">{2F30D19D-5023-4337-88C7-11606832F360}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoName" Type="Str">return value</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoOutputIdx" Type="Int">3</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]CallingConv" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]Name" Type="Str">fixstream_labview_open</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoDir" Type="Int">0</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoInputIdx" Type="Int">10</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoName" Type="Str">reference</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfoCPTM" Type="Bin">%!#!!!!!!!A!"!!!!!N!!Q!%9W^E:1!!"1!&amp;!!!31%!!!@````]!!A2E982B!!!,1!-!"8.U982F!&amp;1!]!!-!!!!!!!!!!-!!!!!!!!!!!!!!!!!!!!%!Q!!?!!!!!!!!!!!!!!!!!!!#1!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!!!!!"B!=!!)!!%!"1!#!!!*=G6G:8*F&lt;G.F!%Y!]!!,!!!!!!!!!!%!!!!!!!!!!!!!!!!!"A-!!/A!!!!!!!!!!!!!!!!!!!E!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!!!!!!%!"Q</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfoVIProtoItemCount" Type="Int">2</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/fixstream_labview_connect.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">ExportedVI</Property>
				<Property Name="Source[2].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoName" Type="Str">return value</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoOutputIdx" Type="Int">2</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[1]VIProtoDir" Type="Int">0</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[1]VIProtoInputIdx" Type="Int">11</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[1]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[1]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[1]VIProtoName" Type="Str">reference</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[1]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[1]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[2]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[2]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[2]VIProtoLenInput" Type="Int">3</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[2]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[2]VIProtoName" Type="Str">data</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[2]VIProtoOutputIdx" Type="Int">3</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[2]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[3]CallingConv" Type="Int">1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[3]Name" Type="Str">fixstream_labview_next</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[3]VIProtoDir" Type="Int">3</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[3]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[3]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[3]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[3]VIProtoName" Type="Str">len</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[3]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[3]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfoCPTM" Type="Bin">%!#!!!!!!!A!"!!!!!N!!Q!%9W^E:1!!"1!&amp;!!!31%!!!@````]!!A2E982B!!!,1!-!"8.U982F!&amp;1!]!!-!!!!!!!!!!-!!!!!!!!!!!!!!!!!!!!%!Q!!?!!!!!!!!!!!!!!!!!!!#1!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!!!!!"B!=!!)!!%!"1!#!!!*=G6G:8*F&lt;G.F!&amp;1!]!!-!!!!!!!"!!-!!!!!!!!!!!!!!!!!!!!'!Q!!?!!!!!!!!!!!!!!*!!!!#1!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!!!!!!%!"Q</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfoVIProtoItemCount" Type="Int">4</Property>
				<Property Name="Source[2].itemID" Type="Ref">/My Computer/fixstream_labview_receive.vi</Property>
				<Property Name="Source[2].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[2].type" Type="Str">ExportedVI</Property>
				<Property Name="Source[3].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoName" Type="Str">return value</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoOutputIdx" Type="Int">3</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]CallingConv" Type="Int">1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]Name" Type="Str">fixstream_labview_close</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoDir" Type="Int">0</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoInputIdx" Type="Int">11</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoName" Type="Str">reference</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfoCPTM" Type="Bin">%!#!!!!!!!A!"!!!!!N!!Q!%9W^E:1!!"1!&amp;!!!31%!!!@````]!!A2E982B!!!,1!-!"8.U982F!&amp;1!]!!-!!!!!!!!!!-!!!!!!!!!!!!!!!!!!!!%!Q!!?!!!!!!!!!!!!!!!!!!!#1!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!!!!!"B!=!!)!!%!"1!#!!!*=G6G:8*F&lt;G.F!&amp;1!]!!-!!!!!!!!!!%!!!!!!!!!!!!!!!!!!!!'!Q!!?!!!!!!!!!!!!!!!!!!!#1!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!!!!!!%!"Q</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfoVIProtoItemCount" Type="Int">2</Property>
				<Property Name="Source[3].itemID" Type="Ref">/My Computer/fixstream_labview_close.vi</Property>
				<Property Name="Source[3].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[3].type" Type="Str">ExportedVI</Property>
				<Property Name="SourceCount" Type="Int">4</Property>
				<Property Name="TgtF_companyName" Type="Str">UDBL</Property>
				<Property Name="TgtF_fileDescription" Type="Str">fixstream_labview</Property>
				<Property Name="TgtF_fileVersion.major" Type="Int">1</Property>
				<Property Name="TgtF_internalName" Type="Str">fixstream_labview</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2011 UDBL</Property>
				<Property Name="TgtF_productName" Type="Str">fixstream_labview</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{A1D8DFA0-FFDE-4A5C-975C-94EC8442F4DE}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">fixstream_labview.dll</Property>
			</Item>
		</Item>
	</Item>
</Project>
