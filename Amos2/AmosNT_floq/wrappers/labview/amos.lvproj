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
		<Item Name="amos_build_tuple.vi" Type="VI" URL="../amos_build_tuple.vi"/>
		<Item Name="amos_error.vi" Type="VI" URL="../amos_error.vi"/>
		<Item Name="amos_function.vi" Type="VI" URL="../amos_function.vi"/>
		<Item Name="amos_init.vi" Type="VI" URL="../amos_init.vi"/>
		<Item Name="amos_query.vi" Type="VI" URL="../amos_query.vi"/>
		<Item Name="amos_scan_close.vi" Type="VI" URL="../amos_scan_close.vi"/>
		<Item Name="amos_scan_eos.vi" Type="VI" URL="../amos_scan_eos.vi"/>
		<Item Name="amos_scan_nextrow.vi" Type="VI" URL="../amos_scan_nextrow.vi"/>
		<Item Name="amos_scan_open_function.vi" Type="VI" URL="../amos_scan_open_function.vi"/>
		<Item Name="amos_scan_open_query.vi" Type="VI" URL="../amos_scan_open_query.vi"/>
		<Item Name="amos_tuple_getdouble.vi" Type="VI" URL="../amos_tuple_getdouble.vi"/>
		<Item Name="amos_tuple_getinteger.vi" Type="VI" URL="../amos_tuple_getinteger.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="VariantType.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/VariantDataType/VariantType.lvlib"/>
			</Item>
			<Item Name="amos.dll" Type="Document" URL="../amos.dll"/>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>
