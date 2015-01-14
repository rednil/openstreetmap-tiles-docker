<Style name="raster">
	<Rule>
		<RasterSymbolizer>
		</RasterSymbolizer>
	</Rule>
</Style>
<Layer name="dem" status="on">
	<StyleName>raster</StyleName>
	<Datasource>
		<Parameter name="type">gdal</Parameter>
		<Parameter name="file">/data/tiff/relief.tif</Parameter>
		<Parameter name="format">tiff</Parameter>
	</Datasource>
</Layer>

