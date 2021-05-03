shinyServer(function(input, output, session) {
    
    
    #Output permettant d'afficher le jeu de données dans l'onglet Présentation
    output$Tableau <- DT::renderDataTable({
        datatable(Trends %>%
            filter(location %in% input$tableauLoc,
                   year %in% input$tableauAnnee,
                   category %in% input$tableauCat,
                   ) %>% 
            mutate(rank = as.integer(rank)),
            #On centre le texte et change le nom des colonnes
            options = list(
                       columnDefs = list(list(className = 'dt-center', targets ="_all"))
                   ),
            colnames = c("Pays", "Année", "Catégorie", "Rang", "Requête"),
            filter = "bottom",
            rownames = F) 
    })
    
    
    #A suivre, la suite d'initialisation côté serveur
    #des sélecteurs de listes qui ont beaucoup d'options
    
    updateSelectizeInput(session, 
                         "tableauLoc", 
                         choices = Trends$location, 
                         server = T, 
                         selected = c("Global"))
    
    observeEvent(input$tableauLoc, {
        #On conditionne les années sélectionnables par rapport aux pays choisis
        Annee <- Trends[Trends$location == input$tableauLoc, "year"]
        updateSelectizeInput(session, 
                             "tableauAnnee", 
                             choices = Annee, 
                             selected = c("2001"))
    })
    
    observeEvent(input$tableauAnnee, {
        #On conditionne les catégories sélectionnables par rapport aux pays et années choisis
        Categorie <- Trends[Trends$location == input$tableauLoc & Trends$year == input$tableauAnnee, "category"]
        updateSelectizeInput(session, 
                             "tableauCat", 
                             choices = Categorie, 
                             selected = c("Consumer Brands"))
    })
    
    #Pour les deux prochaines update, on conserve uniquement les 150
    #requêtes les plus recherchées
    updateSelectizeInput(session, 
                         "visuRequete", 
                         choices = (Trends %>% group_by(query) %>% 
                                                summarise(n = n()) %>% 
                                                filter(n > 10))$query,
                         server = T)
    
    updateSelectizeInput(session, "evoRequete", 
                         choices = (Trends %>% group_by(query) %>% 
                                                summarise(n = n()) %>% 
                                                filter(n > 10))$query,
                         server = T, selected = c("Paul Walker"))
    
    updateSelectizeInput(session, 
                         "evoCatLoc", 
                         choices = Trends$location, 
                         server = T, 
                         selected = c("Global"))
    
    updateSelectizeInput(session, 
                         "compaCatLoc", 
                         choices = Trends$location, 
                         server = T, 
                         selected = c("Global"))
    
    observeEvent(input$compaCatLoc, {
        #On conditionne l'année par rapport au pays
        Annee <- Trends[Trends$location == input$compaCatLoc, "year"]
        updateSelectizeInput(session, 
                             "compaCatAnnee", 
                             choices = Annee, 
                             selected = c(2014,2015))
    })

    
    #Outpout permettant l'affichage du pie
    output$visuPie <- renderPlotly({
        tmp <- Trends %>%
            group_by(location) %>%
            filter(query == input$visuRequete) %>%
            summarise(n=n())
        
        plot_ly(tmp, labels = ~location, values = ~n, type = 'pie',
                textposition = 'inside',
                textinfo = 'label',
                insidetextfont = list(color = '#FFFFFF'),
                hoverinfo = 'text',
                text = ~paste(location, ":", n),
                marker = list(colors = "#466F44",
                              line = list(color = '#FFFFFF', width = 0.5)),
                showlegend = T)
    
    })
    
    #Outpout permettant l'affichage du barplot
    output$visuBars <- renderPlotly({
        tmp <- Trends %>% 
            group_by(location) %>% 
            filter(query == input$visuRequete) %>% 
            summarise(n=n())
        
        plot_ly(tmp, x = ~location, y = ~n, type = 'bar',
                marker = list(color = "#466F44",
                              line = list(color = "#034900",
                                          width = 2))) %>%
            #On enlève le titre des axes
            layout(xaxis = list(title = ""), yaxis = list(title = ""))
    })
    
    #Outpout permettant l'affichage du graphe d'évolution
    output$plotEvoRequete <- renderPlotly({
        tmp <-  Trends %>% 
            filter(query %in% input$evoRequete) %>% 
            group_by(query,year) %>% 
            #On regroupe par requêtes selectionnées et on compte combien par année
            summarise(n = n()) 
        
        fig <- tmp %>%
            plot_ly(
                x = ~year, 
                y = ~n,
                split = ~query,
                type = 'scatter',
                mode = 'lines+markers'
            )
        fig <- fig %>% layout(
            xaxis = list(
                title = "Année",
                zeroline = F
            ),
            yaxis = list(
                title = "",
                zeroline = F
            ),
            title = "Entrées dans un top 5 par année"
        )
        fig
    })
    
    #Outpout permettant l'affichage du graphe d'évolution cumulée
    output$evoCumul <- renderPlotly({
        tmp <-  Trends %>% 
            filter(query %in% input$evoRequete) %>% 
            group_by(query,year) %>% 
            summarise(n = n()) %>% 
            mutate(cumul = cumsum(n))
        
        fig <- tmp %>%
            plot_ly(
                x = ~year, 
                y = ~cumul,
                split = ~query,
                type = 'scatter',
                mode = 'lines+markers'
            )
        fig <- fig %>% layout(
            xaxis = list(
                title = "Année",
                zeroline = F
            ),
            yaxis = list(
                title = "",
                zeroline = F
            ),
            title = "Entrées dans un top 5 cumulées"
        ) 
    })
    
    
    #Output permettant l'affichage du tableau de donnée dans l'onglet Evolution
    output$tableauEvo <- DT::renderDataTable({
        tmp <-  Trends %>% 
            group_by(query) %>% 
            summarise(n = n()) %>% 
            filter(n > 10)
        
        #Comme précédemment on centre le texte et change le nom des colonnes
        datatable(tmp, options = list(
            columnDefs = list(list(className = 'dt-center', targets ="_all"))
        ),
        colnames = c("Requête", "Entrées cumulées"),
        filter = "bottom",
        rownames = F)
    })
    
    #Output permettant l'affichage de l'animation d'évolution des catégories
    output$evoTop <- renderPlotly({
        tmp <- Trends %>%
            filter(location == input$evoCatLoc, year == input$evoCatAnnee) %>% 
            distinct(category) %>% 
            arrange(category) 
        
        #Valeurs associées pour placer les bulles sur le graphe
        tmp$freq <- rep(c(1,2,-0), length.out = nrow(tmp))
        
        #Ici on récupère le nom des catégories et on le sépare
        #par des saut de ligne pour l'adapter aux dimensions des bulles
        tmp$text <- rep(str_split(tmp$category, " "), length.out = nrow(tmp))
        for (i in 1:nrow(tmp)){
            tmp$text[i] <- paste(unlist(tmp$text[i]), collapse = "<br>")
        }
        
        fig <- tmp %>% 
            plot_ly(x=~category, y=~freq, text = ~text, type = "scatter", mode = "markers",
                    marker = list(size = 125, opacity = 0.7, color = "#466F44"),
                    showlegend =F) %>% 
            add_text(textposition = "middle center",
                     textfont = list(size = 12, color = "#000000")) %>%
            #On cache les axes
            layout(xaxis = list(showgrid = FALSE, title = "", showline = F, showticklabels = F, zeroline = F),
                   yaxis = list(showgrid = FALSE, title = "", showline = F, showticklabels = F, zeroline = F))
        fig
    })
    
    #Output permettant la création de la carte
    output$Carte <- renderLeaflet({
        my_countries <- Trends %>% 
            distinct(location) %>% 
            filter(location != "Global") %>% 
            #On renome le nom de certains pays pour pouvoir joindre
            #avec le df contenant les géométries 
            mutate(location = replace(location, location == "Myanmar (Burma)", "Myanmar/Burma"),
                   location = replace(location, location == "Russia", "Russian Federation")) %>% 
            arrange(location)
        
        #On enlève Global qu'on ne peut pas représenter et on choisit l'année
        data_map <- Trends %>% 
            filter(location != c("Global"), year == input$carteAnnee) %>% 
            group_by(location) %>% 
            summarise(n = n()) %>% 
            arrange(location) 
        
        #On va chercher les polygones des pays concernées 
        good_countries <- Monde %>% 
            filter(NAME_ENGL %in% my_countries$location) %>% 
            arrange(NAME_ENGL) %>% 
            inner_join(data_map, by = c("NAME_ENGL" = "location"))
        
        #Création de la palette de couleur
        pal <- colorNumeric(scales::seq_gradient_pal(low = "yellow", 
                                                     high = "red",
                                                     space = "Lab"), 
                            domain = good_countries$n)
        
        leaflet() %>% 
            addTiles() %>% 
            addPolygons(data=good_countries,
                        weight = 2, 
                        color=~pal(good_countries$n),
                        fillOpacity=0.35,
                        popup = ~paste(as.character(good_countries$NAME_ENGL),
                                       as.character(good_countries$n),
                                       sep = " : "
                        )
            ) %>% 
            addLayersControl(options = layersControlOptions(collapsed = F)) %>% 
            addLegend("bottomright", pal = pal, values = good_countries$n,
                      title = "Nombre de requêtes",
                      opacity = 1
            )
    })
    
    #Output permettant la création de la comparaison
    output$compaCat <- renderPlotly({
        tmp <- Trends %>% 
            filter(location == input$compaCatLoc, year %in% input$compaCatAnnee) %>% 
            group_by(year) %>% 
            distinct(category) %>% 
            #Cette variable "a" sert uniquement à placer le texte sur le graphique
            mutate(a = 20, cumul = cumsum(a)) %>% 
            arrange(year, category)
        
        #Premier sous graphe
        fig1 <- tmp[tmp$year==input$compaCatAnnee[1],] %>% 
            plot_ly(
                x = ~a,
                y = ~cumul,
                text = ~category,
                showlegend = F
            ) %>% 
            add_text(
                textposition = "over",
                textfont = list(color = "#466F44",
                                size = 16)
            )%>%
            layout(#Pour le titre de l'axe, on le passe en gras
                   xaxis = list(showgrid = FALSE, title = paste("<b>",as.character(input$compaCatAnnee[1],"<b>")), showline = F, showticklabels = F, zeroline = F),
                   yaxis = list(showgrid = FALSE, title = "", showline = F, showticklabels = F, zeroline = F))
        
        fig1
        
        #Deuxième sous graphe
        fig2 <- tmp[tmp$year==input$compaCatAnnee[2],] %>%
            plot_ly(
                x = ~a,
                y = ~cumul,
                text = ~category,
                showlegend = F
            ) %>% 
            add_text(
                textposition = "over",
                textfont = list(color = "#466F44",
                                size = 16)
            )%>%
            layout(
                   xaxis = list(showgrid = FALSE, title = paste("<b>",as.character(input$compaCatAnnee[2],"<b>")), showline = F, showticklabels = F, zeroline = F),
                   yaxis = list(showgrid = FALSE, title = "", showline = T, showticklabels = F, zeroline = F))
        fig2
        
        #Création du graphe final contenant les deux sous graphes précédents
        fig <- subplot(fig1, fig2, titleX = T) 
        fig
    })
    
})
