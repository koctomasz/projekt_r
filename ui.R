require(leaflet)
require(rdrop2)
require(sp)
require(geosphere)

ui = fluidPage(
  
  titlePanel("Projekt na przedmiot \"Zaawansowany R\""),
  
  mainPanel(
    
    h4(paste0("1.Zaznacz na mapie: ", miasto)),
    p("Liczy się ostatnie kliknięcie na mapie, natomiast pinezka wbija się z opóźnieniem. Czemu? Otóż nie wiem"),
    p("Możliwe, że wynika to z ograniczeń darmowego hostingu"),
    # mapa
    leafletOutput("mymap", height = 500, width = 500),
  
    # pole na tekst
    verbatimTextOutput("tekst")
  
  ),
  
  sidebarPanel("",
    h4("2. Odpowiedz na dwa pytania"),
    hr(),
    radioButtons("plec", "Podaj płeć:",
                       c("kobieta" = "k",
                         "mężczyzna" = "m"),
                 selected = character(0)),
    hr(),
    #p("tylko coś sprawdzam"),
    radioButtons("majonez", "Jaki lubisz majonez?",
                 c("Kielecki" = "kie",
                   "Winiary" = "win",
                   "inny" = "inn",
                   "nie jadam" = "nie"),
                 selected = character(0)),
    hr(),
    #guzik z zapisem 
    conditionalPanel(condition = "input.mymap_click&&input.przycisk<=0&&input.plec.selected!=0&&input.majonez.selected!=0",
                     actionButton("przycisk", "ZAPISZ!"))
    
    )
) 

