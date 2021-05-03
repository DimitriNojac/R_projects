
shinyUI(
    # navbarPage
    navbarPage("Google Trends",
               
               # theme 
               theme = bs_theme(bootswatch = "materia",
                                primary = "#095905"),
               
               # First tab Presentation
               navbarMenu("Présentation",
                          tabPanel("Tableau",
                                   fluidRow(
                                       #first column
                                       column(width = 3,
                                              wellPanel(
                                                selectizeInput("tableauLoc",
                                                            "Sélectionnez vos pays",
                                                            NULL, 
                                                            multiple = T),
                                                selectizeInput("tableauAnnee",
                                                            "Sélectionnez votre période",
                                                            NULL,
                                                            multiple = T),
                                                selectizeInput("tableauCat",
                                                            "Sélectionnez vos catégories",
                                                            NULL,
                                                            multiple = T),
                                                        )
                                              ),
                                       #second column
                                       column(width = 9,
                                              tags$h3("Données : les 5 requêtes les plus recherchées par catégorie par année et par pays", align = "center", size = 25),
                                              tags$hr(),
                                              dataTableOutput("Tableau")
                                              )
                                            )
                                   ),
                          tabPanel("Visualisation",
                                   tags$h3("Répartition par pays pour chacune des 150 requêtes les plus tendances entre 2001 et 2020", align = "center"),
                                   tags$hr(),
                                   tags$br(),
                                   fluidRow(
                                       #First column
                                       column(width = 3,
                                              wellPanel(
                                                  selectInput("visuRequete",
                                                              "Requête",
                                                              NULL,
                                                              )
                                                        )
                                              ),
                                       #Second column
                                       column(width = 9,
                                              tabsetPanel(
                                                  tabPanel("Bars",
                                                           plotlyOutput("visuBars")
                                                           ),
                                                  tabPanel("Pie",
                                                           plotlyOutput("visuPie")
                                                           )
                                                          )
                                              )
                                            )
                                   )
                          ),
               # Second tab
               tabPanel("Evolution",
                        tabsetPanel(
                          tabPanel("Evolution des 150 requêtes les plus présentes dans les tops 5 toutes catégories confondues",
                                    wellPanel(
                                      selectizeInput("evoRequete", 
                                                   "Sélectionnez jusqu'à 5 requêtes", 
                                                   choices = NULL,
                                                   multiple = T,
                                                   options = list(maxItems = 5)
                                                   )
                                    ),
                                   tags$br(),
                                   fluidRow(
                                     column(width = 6,
                                            plotlyOutput("plotEvoRequete")
                                     ),
                                     column(width = 6,
                                            plotlyOutput("evoCumul"))
                                   ),
                                   tags$br(),
                                   dataTableOutput("tableauEvo")
                          ),
                          tabPanel("Evolution des catégories les plus recherchées par pays",
                                   wellPanel(
                                     selectizeInput("evoCatLoc",
                                                    "Sélectionnez le pays",
                                                    NULL, multiple = F)
                                   ),
                                   tags$br(),
                                   plotlyOutput("evoTop"),
                                   sliderInput("evoCatAnnee", 
                                               tags$h3("Année", align = "center"), 
                                               min = 2001, 
                                               max = 2020,
                                               value = 2001,
                                               step = 1, 
                                               #slider animé
                                               animate = animationOptions(
                                                 interval = 1000,
                                                 loop = F
                                               ),
                                               sep = "",
                                               width = "100%",
                                               )
                                   
                          )
                        )
              ),
               # Third tab
               tabPanel("Comparaison",
                        tags$h3("Pour un pays donné, comparaison entre deux années des catégories les plus recherchées", align = "center"),
                        tags$hr(),
                        tags$br(),
                          fluidRow(
                            column(width = 3,
                                   wellPanel(selectizeInput("compaCatLoc", 
                                                            "Sélectionnez le pays", 
                                                            choices = NULL,
                                                            multiple = F
                                                            ),
                                             selectizeInput("compaCatAnnee", 
                                                            "Sélectionnez les deux années à comparer", 
                                                            choices = NULL,
                                                            multiple = T,
                                                            options = list(maxItems = 2)
                                             )
                                            )
                                   ),
                            column(width = 9,
                                   plotlyOutput("compaCat"))
                                  )
                          ),
               # Forth tab
               tabPanel("Carte",
                        tags$h3("Carte représentant pour chaque année le nombre de requêtes tendances par pays", align = "center"),
                        tags$hr(),
                        tags$br(),
                        fluidRow(
                          column(width = 3,
                                 wellPanel(sliderInput("carteAnnee", 
                                             "Année", 
                                             min = 2002, 
                                             max = 2020,
                                             value = 2020,
                                             step = 1, 
                                             sep = "",
                                             width = "100%",
                                 )
                                 )
                          ),
                          column(width = 9,
                                 leafletOutput("Carte")
                                 )
                        )
                        )
    )
)
                                                    