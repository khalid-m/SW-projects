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
		<Item Name="sandvik_close.vi" Type="VI" URL="../sandvik_close.vi"/>
		<Item Name="sandvik_global.vi" Type="VI" URL="../sandvik_global.vi"/>
		<Item Name="sandvik_next.vi" Type="VI" URL="../sandvik_next.vi"/>
		<Item Name="sandvik_open.vi" Type="VI" URL="../sandvik_open.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="Internecine Avoider.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/tcp.llb/Internecine Avoider.vi"/>
				<Item Name="TCP Listen Internal List.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/tcp.llb/TCP Listen Internal List.vi"/>
				<Item Name="TCP Listen List Operations.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/tcp.llb/TCP Listen List Operations.ctl"/>
				<Item Name="TCP Listen.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/tcp.llb/TCP Listen.vi"/>
			</Item>
		</Item>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="Sandvik read data" Type="DLL">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{55ABB5E9-B552-43EC-AED7-113A9B970437}</Property>
				<Property Name="App_INI_GUID" Type="Str">{B68F1C30-0D7B-47E9-9CB8-E9BB991287DD}</Property>
				<Property Name="App_winsec.description" Type="Str">http://www.FALSE.com</Property>
				<Property Name="Bld_buildSpecName" Type="Str">Sandvik read data</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">..</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Destination[0].destName" Type="Str">sandvik_read.dll</Property>
				<Property Name="Destination[0].path" Type="Path">../sandvik_read.dll</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../visualize_sandvik/data</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="Dll_delayOSMsg" Type="Bool">true</Property>
				<Property Name="Dll_headerGUID" Type="Str">{E827646A-E46E-4926-A068-7A4C5DF553C4}</Property>
				<Property Name="Dll_libGUID" Type="Str">{ED1001D5-466F-4C52-AD27-484AC8306DEB}</Property>
				<Property Name="Source[0].itemID" Type="Str">{4B8A7795-3415-4B37-84FC-8D3BE3A7A886}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoName" Type="Str">return value</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoPassBy" Type="Int">0</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]CallingConv" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]Name" Type="Str">open</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoDir" Type="Int">0</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoInputIdx" Type="Int">11</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoName" Type="Str">String</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfoCPTM" Type="Bin">%!#!!!!!!!-!"!!!!""!-0````]'5X2S;7ZH!!"5!0!!$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1-!!(A!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#!!!!!!"!!)</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfoVIProtoItemCount" Type="Int">2</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/sandvik_open.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">ExportedVI</Property>
				<Property Name="Source[2].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]CallingConv" Type="Int">1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]Name" Type="Str">close</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoName" Type="Str">return value</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfo[0]VIProtoPassBy" Type="Int">0</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfoCPTM" Type="Bin">%!#!!!!!!!)!"!!!!&amp;1!]!!-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!A!!?!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%!!1</Property>
				<Property Name="Source[2].ExportedVI.VIProtoInfoVIProtoItemCount" Type="Int">1</Property>
				<Property Name="Source[2].itemID" Type="Ref">/My Computer/sandvik_close.vi</Property>
				<Property Name="Source[2].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[2].type" Type="Str">ExportedVI</Property>
				<Property Name="Source[3].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoName" Type="Str">return value</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[0]VIProtoPassBy" Type="Int">0</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoLenInput" Type="Int">2</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoName" Type="Str">data</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoOutputIdx" Type="Int">3</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[1]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[2]CallingConv" Type="Int">1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[2]Name" Type="Str">next</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[2]VIProtoDir" Type="Int">3</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[2]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[2]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[2]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[2]VIProtoName" Type="Str">len</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[2]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfo[2]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfoCPTM" Type="Bin">%!#!!!!!!!1!"!!!!!V!"1!(4H6N:8*J9Q!31%!!!@````]!!12E982B!!"5!0!!$!!!!!!!!!!#!!!!!!!!!!!!!!!!!!!!!!-!!(A!!!!!!!!!!!!!!!!!!!E!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"!!-</Property>
				<Property Name="Source[3].ExportedVI.VIProtoInfoVIProtoItemCount" Type="Int">3</Property>
				<Property Name="Source[3].itemID" Type="Ref">/My Computer/sandvik_next.vi</Property>
				<Property Name="Source[3].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[3].type" Type="Str">ExportedVI</Property>
				<Property Name="SourceCount" Type="Int">4</Property>
				<Property Name="TgtF_companyName" Type="Str">UDBL</Property>
				<Property Name="TgtF_fileDescription" Type="Str">Sandvik read data</Property>
				<Property Name="TgtF_fileVersion.major" Type="Int">1</Property>
				<Property Name="TgtF_internalName" Type="Str">Sandvik read data</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2011 UDBL</Property>
				<Property Name="TgtF_productName" Type="Str">Sandvik read data</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{9DF65137-0FD4-42FB-8288-774E02BFDA5F}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">sandvik_read.dll</Property>
			</Item>
		</Item>
	</Item>
</Project>
