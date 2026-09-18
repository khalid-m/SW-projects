
for $b in //*/*/*/GetPlaceListResult/PlaceFacts
return
<GetPlaceList>
  {$b/Place/City,$b/Place/State,$b/Place/Country,$b/Center/Lon,$b/Center/Lat,$b/AvailableThemeMask,$b/PlaceTypeId,$b/Population}	 
</GetPlaceList>