library(ggplot2)

load('mapping.RData')

p11 <- ggplot(bbox_robin_df, aes(long, lat, group=group)) + 
    geom_polygon(fill="white") + 
    geom_path(data=grat_df_robin, aes(long, lat, group=group, fill=NULL), 
                 linetype="dashed", color="grey50") +
    labs(title="World map (Robinson)") + 
    coord_equal() + 
    theme_opts +
    scale_colour_gradient(limits=c(3, 10))

p21 <- ggplot(countries_robin_df) + coord_equal() + theme_opts

plot_map1 <- function(variable) {
    p <- p11 + geom_polygon(data=countries_robin_df, 
                            aes_string('long', 'lat', group='group', 
                                       fill=variable)) + 
        geom_path(data=countries_robin_df, 
                  aes_string('long', 'lat', group='group', 
                             fill=variable), 
                  color="white", size=0.3)
    plot(p)
}

plot_map2 <- function(variable) {
    # simpler but no projection
    p <- p21 + 
        geom_polygon(aes_string('long', 'lat', group='group', 
                                fill=variable))
    plot(p)
}


get_map2 <- function(variable) {
    p21 + geom_polygon(aes_string('long', 'lat', 
                                  group='group', fill=variable))
}

get_map1 <- function(variable) {
    p <- p11 + geom_polygon(data=countries_robin_df, 
                            aes_string('long', 'lat', group='group', 
                                       fill=variable)) + 
        geom_path(data=countries_robin_df, 
                  aes_string('long', 'lat', group='group', 
                             fill=variable), 
                  color="white", size=0.3)
    p
}

save(list=c('p11', 'p21', 'plot_map1', 'plot_map2', 
'get_map1', 'get_map2', 'countries_robin_df'), 
file='app/map_base.RData')


