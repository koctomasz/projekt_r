install.packages("rdrop2")
install.packages("geosphere")

library(rvest)
library(rdrop2)
library(shiny)
library(leaflet)
library(geosphere)
library(sp)
library(dplyr)
library(ggplot2)

#autoryzowanie konta na dropbox
drop_auth()
token <- drop_auth()
saveRDS(token, file = "token.rds")

#wrzucanie projektu na serwer
rsconnect::deployApp("projekt")
Y


#webscraping
miasta=c("Warszawa", "Wrocław", "Kraków", "Gdańsk", "Szczecin")
tabela=NULL
for (x in miasta)
{
  dane=read_html(paste0("https://pl.wikipedia.org/wiki/", x))
  lng=dane %>%
    html_node(".longitude") %>%
    html_text()
  #przetwarzanie otrzymanego tekstu na format "zjadliwy" dla funkcji char2dms
  lng = paste0(substr(lng, 1,2),"d",substr(lng, 4,5),"'",substr(lng, 7,8),"\"",substr(lng, 10,10))
  lng = as.numeric(char2dms(lng))
  lat=dane %>%
    html_node(".latitude") %>%
    html_text()
  lat = paste0(substr(lat, 1,2),"d",substr(lat, 4,5),"'",substr(lat, 7,8),"\"",substr(lat, 10,10))
  lat=as.numeric(char2dms((lat)))
  tabela[[x]]=c(lat, lng)
    
}

#zapisywanie zescrapowanych danych
print(tabela)
tabela=as.data.frame(tabela)
rownames(tabela) = c("lat", "long")
write.csv(tabela, "tab.csv")

#przetwarzanie zgromadzonych obserwacji
l = list.files(pattern="*.csv")
d = do.call("rbind", lapply( l, read.csv, header=TRUE))
print(d)
colnames(d) = c("blad", "miasto", "plec", "majonez")


#wykresy do prezentacji
ggplot(d, aes(x=majonez, fill=plec )) + 
     geom_bar(position = "fill") +
     labs(title = "Preferencje majonezu względem płci",
                   x = "majonez",
                   y = "") +
     theme(axis.text.y = element_blank()) +
     scale_x_discrete(labels=c("kie" = "Kielecki", "win" = "Winiary",
                               "inn" = "inny", "nie" = "nie jem")) +
     scale_fill_discrete(labels=c("m"="mężczyźni", "k" = "kobiety"),
                          name = "płeć")


dd=d %>%
  filter(blad<150) %>%
  select(miasto, blad) %>%
  group_by(miasto)%>%
  summarise(mean(blad))
print(dd)

ggplot(dd, aes(x=miasto, y=`mean(blad)`))+ 
  geom_col(fill = c("grey50", "grey50", "red", "green", "grey50")) +
  labs(title = "Które miasto najtrudniej wskazać na mapie",
       x = "Miasto",
       y = "Średni bład odległości") +
  scale_x_discrete(labels=c("Wrocław", "Szczecin", "Kraków", "Gdańsk", "Warszawa"))
  
ddd=d %>%
  filter(blad<150) %>%
  select(majonez, blad) %>%
  group_by(majonez)%>%
  summarise(mean(blad))
print(ddd)

ggplot(ddd, aes(x=majonez, y=`mean(blad)`))+ 
  geom_col(fill = c("grey50", "red", "grey50", "green")) +
  labs(title = "Spożywany majonez a umiejętność wskazania miast Polski na mapie",
       x = "Majonez",
       y = "Średni bład odległości") +
  scale_x_discrete(labels=c("Kielecki", "Winiary", "inny", "nie jem"))


