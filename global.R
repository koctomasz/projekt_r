require(leaflet)
require(rdrop2)
require(sp)
require(geosphere)

#tabela ze wspolrzednymi
wspolrzedne = read.csv("tab.csv", encoding = "UTF-8")
rownames(wspolrzedne) = wspolrzedne$X
wspolrzedne$X=NULL

#losowanie miasta
x = sample(1:length(wspolrzedne), 1)
miasto = colnames(wspolrzedne)[x]

