@contour: #333;
@minmed: 6;
@medmax: 12;

#contours1000 {
	[zoom >= 8] {
		line-color: @contour;
		line-smooth: 1;
		line-width: 0.5;
		line-opacity: 0.4;
	}
	[zoom >= 10] {
		line-opacity: 0.6;
	}
	[zoom >= 12] {
		line-opacity: 0.8;
		text-halo-radius: 1;
		text-face-name: @book-fonts;
		text-name: [height];
		text-size: 8;
		text-placement: line;
		text-fill: @contour;
	}
}


#contours500 {
	[zoom >= 10] {
		line-color: @contour;
		line-smooth: 1;
		line-opacity: 0.4;
		line-width: 0.5;
	}
	[zoom >= 12] {
		line-opacity: 0.6;
	}
	[zoom >= 14] {
		line-opacity: 0.8;
		text-halo-radius: 1;
		text-face-name: @book-fonts;
		text-name: [height];
		text-size: 8;
		text-placement: line;
		text-fill: @contour;
	}
}


#contours100 {
	[zoom >= 12] {
		line-color: @contour;
		line-smooth: 1;
		line-opacity: 0.4;
		line-width: 0.5;
	}
	[zoom >= 14] {
		line-opacity: 0.6;
	}
	[zoom >= 17] {
		line-opacity: 0.8;
		text-halo-radius: 1;
		text-face-name: @book-fonts;
		text-name: [height];
		text-size: 8;
		text-placement: line;
		text-fill: @contour;
	}
}
#contours50 {
	[zoom >= 14] {
		line-smooth: 1;
		line-color: @contour;
		line-width: 0.5;
		line-opacity: 0.4;
	}
	[zoom >= 17] {
		line-opacity: 0.6;
	}
}
#contours10 {
	[zoom >= 15] {
		line-color: @contour;
		line-smooth: 1;
		line-width: 0.5;
		line-opacity: 0.2;
	}
}

#hillshadeMin {
   	[zoom < @minmed ] {
		raster-opacity: 0.5;
	}
}
#hillshadeMed {
	[zoom >= @minmed][zoom <= @medmax] {
		raster-opacity: 0.3;
	}
	[zoom >= @minmed][zoom <= 11 ] {
		raster-opacity: 0.4;
	}
	[zoom >= @minmed][zoom <= 9 ] {
		raster-opacity: 0.5;
	}
}
#hillshadeMax {
	[zoom > @medmax] {
		raster-opacity: 0.2;
	}
	[zoom > @medmax][zoom <= 15] {
		raster-opacity: 0.1;
	}
}

#reliefMin {
	[zoom < @minmed]{
		raster-opacity: 1;
	}
}
#reliefMed {
	[zoom >= @minmed][zoom <= @medmax]{
		raster-opacity: 1;
	}
}
#reliefMax {
	[zoom > @medmax]{
		raster-opacity: 1;
	}
}

