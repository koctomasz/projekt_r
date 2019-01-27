require(leaflet)
require(rdrop2)
require(sp)
require(geosphere)

server = function(input, output, session) {
  
  #początkowe ustawienie mapy, zakazuję użytkownikowi przesuwać czy zoomować
  output$mymap = renderLeaflet(
    leaflet(options = leafletOptions(minZoom=6, maxZoom=6, dragging=FALSE, doubleClickZoom=FALSE)) %>%
      addProviderTiles(providers$Esri.WorldGrayCanvas) %>%
      
      #mapa pokazuje Polskę na początek
      setView(lng = 19.15, lat = 52.19, zoom = 6)
      
  )
 
  # czekamy na kliknięcie w mapę
  observeEvent(input$mymap_click, {
   
    #na mapie
    leafletProxy("mymap") %>%
      #czyścimy markery
      clearMarkers() %>%
      #ustawiamy marker w miejscu gdzie kliknięto
      addMarkers(lng = input$mymap_click$lng, lat = input$mymap_click$lat) 
  
  })
  
  #przy kliknięciu przycisku "ZAPISZ!"
  observeEvent(input$przycisk, {
   
    #zapisuję współrzędne wylosowanego miasta
    lat = wspolrzedne[1,x ]
    lng = wspolrzedne[2,x ]
    
    #pokazuję na mapie wylosowane miasto
    leafletProxy("mymap") %>% addMarkers(lat = lat, lng = lng)
    
    #liczę bład i go wyświetlam
    blad = round((geosphere::distm(x = c(input$mymap_click$lng, input$mymap_click$lat),
                        y = c(lng, lat),
                        fun = distHaversine))/1000, digits = 1)
    
    output$tekst = renderPrint({
      cat("pomyliłeś się o: ", blad, " kilometrów")
      })
    
    #zapisuję dane
    zapiszDane(blad, miasto, input$plec, input$majonez)
    
    #pokazuję alert
    showNotification("Dziękuję za udział w ankiecie!")
  })
 
  #nazwa folderu na dropbox gdzie beda zapisywane dane
  outputDir = "R"
  
  #funkcja zapisu
  zapiszDane = function(x,y,z,t) {
    data = cbind(x,y,z,t)
    #stworzenie unikalnej nazwy
    fileName = sprintf("%s_%s.csv", as.integer(Sys.time()), digest::digest(data))
    #tymczasowe zapisanie pliku na serwerze shinyapps
    filePath = file.path(tempdir(), fileName)
    write.csv(data, filePath, row.names = FALSE, quote = TRUE)
    #załadowanie do dropboxa
    drop_upload(filePath, path = outputDir)
  
  }
} 

