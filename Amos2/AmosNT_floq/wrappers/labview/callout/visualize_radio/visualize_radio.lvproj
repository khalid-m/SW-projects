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
		<Item Name="visualize_radio.vi" Type="VI" URL="../visualize_radio.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="3D Mesh Datatype.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Mesh/3D Mesh Datatype/3D Mesh Datatype.lvclass"/>
				<Item Name="3D Mesh.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Mesh/3D Mesh/3D Mesh.lvclass"/>
				<Item Name="3D Mesh.xctl" Type="XControl" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Mesh/3D Mesh XCtrl/3D Mesh.xctl"/>
				<Item Name="3D Plot Datatype.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/3D Plot Datatype/3D Plot Datatype.lvclass"/>
				<Item Name="3D Plot.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/3D Plot/3D Plot.lvclass"/>
				<Item Name="3D Projection.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/3D Projection.ctl"/>
				<Item Name="3D Surface Datatype.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Surface/3D Surface Datatype/3D Surface Datatype.lvclass"/>
				<Item Name="3D Surface.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Surface/3D Surface/3D Surface.lvclass"/>
				<Item Name="3DMathPlot Action String.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Action String/3DMathPlot Action String.ctl"/>
				<Item Name="3DMathPlot Action String.vi" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Action String/3DMathPlot Action String.vi"/>
				<Item Name="3DMathPlot Ctrl Act Cluster.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Action String/3DMathPlot Ctrl Act Cluster.ctl"/>
				<Item Name="3DMathPlot Ctrl Act Queue.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Action String/3DMathPlot Ctrl Act Queue.ctl"/>
				<Item Name="3DMathPlot State Class.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Action String/3DMathPlot State Class.ctl"/>
				<Item Name="Check if File or Folder Exists.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Check if File or Folder Exists.vi"/>
				<Item Name="Clear Errors.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Clear Errors.vi"/>
				<Item Name="Color Slider.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/Color Slider.ctl"/>
				<Item Name="Color to RGB.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/colorconv.llb/Color to RGB.vi"/>
				<Item Name="Delete.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/Delete.ctl"/>
				<Item Name="Draw Flattened Pixmap.vi" Type="VI" URL="/&lt;vilib&gt;/picture/picture.llb/Draw Flattened Pixmap.vi"/>
				<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Cluster From Error Code.vi"/>
				<Item Name="FixBadRect.vi" Type="VI" URL="/&lt;vilib&gt;/picture/pictutil.llb/FixBadRect.vi"/>
				<Item Name="Get Text Rect.vi" Type="VI" URL="/&lt;vilib&gt;/picture/picture.llb/Get Text Rect.vi"/>
				<Item Name="imagedata.ctl" Type="VI" URL="/&lt;vilib&gt;/picture/picture.llb/imagedata.ctl"/>
				<Item Name="Line Style Ring.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/Line Style Ring.ctl"/>
				<Item Name="LV3DPointTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LV3DPointTypeDef.ctl"/>
				<Item Name="LVRectTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVRectTypeDef.ctl"/>
				<Item Name="Move Down.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/Move Down.ctl"/>
				<Item Name="Move Up.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/Move Up.ctl"/>
				<Item Name="New.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/New.ctl"/>
				<Item Name="NI_3D Picture Control.lvlib" Type="Library" URL="/&lt;vilib&gt;/picture/3D Picture Control/NI_3D Picture Control.lvlib"/>
				<Item Name="NI_FileType.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/lvfile.llb/NI_FileType.lvlib"/>
				<Item Name="NI_Math Plot Private Lib.lvlib" Type="Library" URL="/&lt;vilib&gt;/Math Plots/Plot Private Lib/NI_Math Plot Private Lib.lvlib"/>
				<Item Name="Point Style Ring.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/Point Style Ring.ctl"/>
				<Item Name="RGB to Color.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/colorconv.llb/RGB to Color.vi"/>
				<Item Name="Trim Whitespace.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Trim Whitespace.vi"/>
				<Item Name="Version To Dotted String.vi" Type="VI" URL="/&lt;vilib&gt;/_xctls/Version To Dotted String.vi"/>
				<Item Name="whitespace.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/whitespace.ctl"/>
				<Item Name="XControlSupport.lvlib" Type="Library" URL="/&lt;vilib&gt;/_xctls/XControlSupport.lvlib"/>
				<Item Name="XY Projection.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/XY Projection.ctl"/>
				<Item Name="XZ Projection.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/XZ Projection.ctl"/>
				<Item Name="YZ Projection.ctl" Type="VI" URL="/&lt;vilib&gt;/Math Plots/3D Math Plots/3D Plot/Buttons/YZ Projection.ctl"/>
			</Item>
			<Item Name="_LaunchHelp.vi" Type="VI" URL="/&lt;helpdir&gt;/_LaunchHelp.vi"/>
		</Item>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="Visualize radio" Type="DLL">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{13D27EE3-F7AC-470A-8C8C-3CAB19DF8A1C}</Property>
				<Property Name="App_INI_GUID" Type="Str">{2FBFA392-2992-4F48-9843-D522C6083B1C}</Property>
				<Property Name="App_winsec.description" Type="Str">http://www.FALSE.com</Property>
				<Property Name="Bld_buildSpecName" Type="Str">Visualize radio</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">..</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Destination[0].destName" Type="Str">visualize_radio.dll</Property>
				<Property Name="Destination[0].path" Type="Path">../NI_AB_PROJECTNAME.dll</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../data</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="Dll_delayOSMsg" Type="Bool">true</Property>
				<Property Name="Dll_headerGUID" Type="Str">{3E46B9D6-E90B-495C-9C89-6EB12E47BC8A}</Property>
				<Property Name="Dll_libGUID" Type="Str">{86E9E808-5B0A-42D6-A36C-41D9E1346635}</Property>
				<Property Name="Source[0].itemID" Type="Str">{E9E86D0B-6E43-4930-8AAC-9BA13FF78497}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoDir" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoName" Type="Str">return value</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[0]VIProtoPassBy" Type="Int">0</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoDir" Type="Int">0</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoInputIdx" Type="Int">11</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoLenInput" Type="Int">2</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoName" Type="Str">Input</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[1]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[2]CallingConv" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[2]Name" Type="Str">next</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[2]VIProtoDir" Type="Int">3</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[2]VIProtoInputIdx" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[2]VIProtoLenInput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[2]VIProtoLenOutput" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[2]VIProtoName" Type="Str">len</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[2]VIProtoOutputIdx" Type="Int">-1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfo[2]VIProtoPassBy" Type="Int">1</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfoCPTM" Type="Bin">%!#!!!!!!!1!"!!!!!V!#A!(4H6N:8*J9Q!31%!!!@````]!!16*&lt;H"V&gt;!"5!0!!$!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!A-!!(A!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#!!!!!!"!!-</Property>
				<Property Name="Source[1].ExportedVI.VIProtoInfoVIProtoItemCount" Type="Int">3</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/visualize_radio.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">ExportedVI</Property>
				<Property Name="SourceCount" Type="Int">2</Property>
				<Property Name="TgtF_companyName" Type="Str">UDBL</Property>
				<Property Name="TgtF_fileDescription" Type="Str">Visualize radio</Property>
				<Property Name="TgtF_fileVersion.major" Type="Int">1</Property>
				<Property Name="TgtF_internalName" Type="Str">Visualize radio</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2011 UDBL</Property>
				<Property Name="TgtF_productName" Type="Str">Visualize radio</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{CFF46793-4503-442B-B520-4A27E3FE7A4F}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">visualize_radio.dll</Property>
			</Item>
		</Item>
	</Item>
</Project>
