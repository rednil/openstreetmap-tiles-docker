<Style name="contours10">
        <Rule>
                <MaxScaleDenominator>8530</MaxScaleDenominator>
                <MinScaleDenominator>2132</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.5" />
        </Rule>
</Style>
<Style name="contours50">
        <Rule>
                <MaxScaleDenominator>34123</MaxScaleDenominator>
                <MinScaleDenominator>8530</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.5" />
        </Rule>
        <Rule>
                <MaxScaleDenominator>8530</MaxScaleDenominator>
                <MinScaleDenominator>2132</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.6" />
        </Rule>
</Style>
<Style name="contours100">
        <Rule>
                <MaxScaleDenominator>136494</MaxScaleDenominator>
                <MinScaleDenominator>34123</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.5" />
        </Rule>
        <Rule>
                <MaxScaleDenominator>34123</MaxScaleDenominator>
                <MinScaleDenominator>8530</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.6" />
        </Rule>
        <Rule>
                <MaxScaleDenominator>8530</MaxScaleDenominator>
                <MinScaleDenominator>2132</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.7" />
        </Rule>
</Style>
<Style name="contours500">
	<Rule>
                <MaxScaleDenominator>545978</MaxScaleDenominator>
                <MinScaleDenominator>136494</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.5" />
        </Rule>
	<Rule>
                <MaxScaleDenominator>136494</MaxScaleDenominator>
                <MinScaleDenominator>34123</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.6" />
        </Rule>
        <Rule>
                <MaxScaleDenominator>34123</MaxScaleDenominator>
                <MinScaleDenominator>8530</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.7" />
        </Rule>
        <Rule>
                <MaxScaleDenominator>8530</MaxScaleDenominator>
                <MinScaleDenominator>2132</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.8" />
        </Rule>
</Style>
<Style name="contours1000">
	 <Rule>
                <MaxScaleDenominator>2183915</MaxScaleDenominator>
                <MinScaleDenominator>545978</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.5" />
        </Rule>
	<Rule>
                <MaxScaleDenominator>545978</MaxScaleDenominator>
                <MinScaleDenominator>136494</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.6" />
        </Rule>
        <Rule>
                <MaxScaleDenominator>136494</MaxScaleDenominator>
                <MinScaleDenominator>34123</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.7" />
        </Rule>
        <Rule>
                <MaxScaleDenominator>34123</MaxScaleDenominator>
                <MinScaleDenominator>8530</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.8" />
        </Rule>
        <Rule>
                <MaxScaleDenominator>8530</MaxScaleDenominator>
                <MinScaleDenominator>2132</MinScaleDenominator>
                <LineSymbolizer stroke="#6f373a" stroke-width="0.9" />
        </Rule>
</Style>
<Style name="contours-text50">
        <Rule>
                <MaxScaleDenominator>8530</MaxScaleDenominator>
                <MinScaleDenominator>2132</MinScaleDenominator>
                <TextSymbolizer size="8" fill="#9c9" fontset-name="bold-fonts" halo-radius="1" wrap-width="14">[name]</TextSymbolizer>
                <TextSymbolizer face-name="DejaVu Sans Book" size="8" fill="#6f373a" halo-radius="1" placement="line">[height]</TextSymbolizer>
        </Rule>
</Style>
<Style name="contours-text100">
        <Rule>
                <MaxScaleDenominator>136494</MaxScaleDenominator>
                <MinScaleDenominator>2132</MinScaleDenominator>
                <TextSymbolizer face-name="DejaVu Sans Book" size="8" fill="#6f373a" halo-radius="1" placement="line" >[height]</TextSymbolizer>
        </Rule>
</Style>
<Style name="contours-text1000">
        <Rule>
                <MaxScaleDenominator>545978</MaxScaleDenominator>
                <MinScaleDenominator>2132</MinScaleDenominator>
                <TextSymbolizer face-name="DejaVu Sans Book" size="8" fill="#6f373a" halo-radius="1" placement="line" >[height]</TextSymbolizer>
        </Rule>
</Style>
<Layer name="srtm_10" status="on" srs="+proj=latlong +datum=WGS84">
        <StyleName>contours10</StyleName>
        <StyleName>contours-text10</StyleName>
        <Datasource>
      &datasource-settings;
                <Parameter name="table">(SELECT way,height,height as name FROM contours WHERE height::integer % 10 = 0 AND height::integer % 50 != 0) AS "contours-10"</Parameter>
        </Datasource>
</Layer>
<Layer name="srtm_50" status="on" srs="+proj=latlong +datum=WGS84">
        <StyleName>contours50</StyleName>
        <StyleName>contours-text50</StyleName>
        <Datasource>
      &datasource-settings;
                <Parameter name="table">(SELECT way,height,height as name FROM contours WHERE height::integer % 50 = 0 AND height::integer % 100 != 0) AS "contours-50"</Parameter>
        </Datasource>
</Layer>
<Layer name="srtm_100" status="on" srs="+proj=latlong +datum=WGS84">
        <StyleName>contours100</StyleName>
        <StyleName>contours-text100</StyleName>
        <Datasource>
      &datasource-settings;
                <Parameter name="table">(SELECT way,height,height as name FROM contours WHERE height::integer % 100 = 0 AND height::integer % 500 != 0) AS "contours-100"</Parameter>
        </Datasource>
</Layer>
<Layer name="srtm_500" status="on" srs="+proj=latlong +datum=WGS84">
        <StyleName>contours500</StyleName>
        <StyleName>contours-text500</StyleName>
        <Datasource>
      &datasource-settings;
                <Parameter name="table">(SELECT way,height,height as name FROM contours WHERE height::integer % 500 = 0 AND height::integer % 1000 != 0) AS "contours-500"</Parameter>
        </Datasource>
</Layer>
<Layer name="srtm_1000" status="on" srs="+proj=latlong +datum=WGS84">
        <StyleName>contours1000</StyleName>
        <StyleName>contours-text1000</StyleName>
        <Datasource>
      &datasource-settings;
                <Parameter name="table">(SELECT way,height,height as name FROM contours WHERE height::integer % 1000 = 0) AS "contours-1000"</Parameter>
        </Datasource>
</Layer>
