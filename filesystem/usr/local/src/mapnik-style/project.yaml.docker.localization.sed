/"nature-reserve-boundaries"/,/- id: "/ s/name([^:s"])/GET_LOCALIZED AS name\1/
/"placenames-large"/,/- id: "/ s/name([^:s"])/GET_LOCALIZED AS name\1/
/"placenames-capital"/,/- id: "/ s/name([^:s"])/GET_LOCALIZED AS name\1/
/"placenames-medium"/,/- id: "/ s/name([^:s"])/GET_LOCALIZED AS name\1/
/"placenames-small"/,/- id: "/ s/name([^:s"])/GET_LOCALIZED AS name\1/
/"text-point"/,/- id: "/ s/CONCAT\(name/CONCAT(GET_LOCALIZED/
/"text-point"/,/- id: "/ s/ELSE name/ELSE GET_LOCALIZED/
