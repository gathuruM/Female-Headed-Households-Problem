
rgriffin · 3y ago · 53,005 views
Olympic history data: thorough analysis
Rmarkdown · 120 years of Olympic history: athletes and results
silver medal
Run

28.7s

---
title: 'Olympic history: a thorough analysis'
output:
  html_document:
    number_sections: true
    toc: true
    fig_width: 8
    fig_height: 5
    theme: cosmo
    highlight: tango
    code_folding: hide
---

# Introduction

The 'modern Olympics' comprises all the Games from Athens 1986 to Rio 2016. The Olympics is more than just a quadrennial multi-sport world championship. It is a lense through which to understand global history, including shifting geopolitical power dynamics, women's empowerment, and the evolving values of society. 

In this kernel, my goal is to shed light on major patterns in Olympic history. How many athletes, sports, and nations are there? Where do most athletes come from? Who wins medals? What are the characteristic of the athletes (e.g., gender and physical size)? 

I also zoom in on some particuarly interesting aspects of Olympic history that you might not know about. Did you know that Nazi Germany hosted the 1936 Olympics and they totally kicked everyone's asses? Did you know that painting and poetry used to be Olympic events? These are the sort of tidbits I like to sprinkle in.

I scraped this data from www.sports-reference.com, which hosts a detailed database on Olympic history, which is developed and maintained by an independent group of [Olympic statistorians](http://olympstats.com/2016/08/21/the-olymadmen-and-olympstats-and-sports-reference/). The script I used to scrape the data is [here](https://github.com/rgriff23/Olympic_history/blob/master/R/olympics%20scrape.R), and the code I used to wrangle it is [here](https://github.com/rgriff23/Olympic_history/blob/master/R/olympics%20wrangle.R). 

# Preparations

Load packages and data. 

```{r, message=FALSE, warning=FALSE}
# Load packages
library("plotly")
library("tidyverse")
library("data.table")
library("gridExtra")
library("knitr")

# Load athletes_events data 
data <- read_csv("../input/athlete_events.csv",
                 col_types = cols(
                   ID = col_character(),
                   Name = col_character(),
                   Sex = col_factor(levels = c("M","F")),
                   Age =  col_integer(),
                   Height = col_double(),
                   Weight = col_double(),
                   Team = col_character(),
                   NOC = col_character(),
                   Games = col_character(),
                   Year = col_integer(),
                   Season = col_factor(levels = c("Summer","Winter")),
                   City = col_character(),
                   Sport = col_character(),
                   Event = col_character(),
                   Medal = col_factor(levels = c("Gold","Silver","Bronze"))
                 )
)

# Options
opts_chunk$set(warning=FALSE, message=FALSE)
```

# More athletes, nations, and events

## Has the number of athletes, nations, and events changed over time?

```{r growth_over_time, fig.width=8, fig.height=8}
# count number of athletes, nations, & events, excluding the Art Competitions
counts <- data %>% filter(Sport != "Art Competitions") %>%
  group_by(Year, Season) %>%
  summarize(
    Athletes = length(unique(ID)),
    Nations = length(unique(NOC)),
    Events = length(unique(Event))
  )

# plot
p1 <- ggplot(counts, aes(x=Year, y=Athletes, group=Season, color=Season)) +
  geom_point(size=2) +
  geom_line() +
  scale_color_manual(values=c("darkorange","darkblue")) +
  xlab("") +  
  annotate("text", x=c(1932,1956,1976,1980),
           y=c(2000,2750,6800,4700),
           label=c("L.A. 1932","Melbourne 1956","Montreal 1976","Moscow 1980"),
           size=3) +
  annotate("text",x=c(1916,1942),y=c(10000,10000),
           label=c("WWI","WWII"), size=4, color="red") +
  geom_segment(mapping=aes(x=1914,y=8000,xend=1918,yend=8000),color="red", size=2) +
  geom_segment(mapping=aes(x=1939,y=8000,xend=1945,yend=8000),color="red", size=2)
p2 <- ggplot(counts, aes(x=Year, y=Nations, group=Season, color=Season)) +
  geom_point(size=2) +
  geom_line() +
  scale_color_manual(values=c("darkorange","darkblue")) +
  xlab("") +  
  annotate("text", x=c(1932,1976,1980),
           y=c(60,105,70),
           label=c("L.A. 1932","Montreal 1976","Moscow 1980"),
           size=3)
p3 <- ggplot(counts, aes(x=Year, y=Events, group=Season, color=Season)) +
  geom_point(size=2) +
  geom_line() +
  scale_color_manual(values=c("darkorange","darkblue"))
grid.arrange(p1, p2, p3, ncol=1)
```

You can see two long periods without any Games between 1912-1920 and 1936-1948, corresponding to WWI and WWII. In addition, a few Games are highlighted where dips occur in one or more of the plots:

- **L.A., 1932:** Attendance dipped because these Games occured in the midst of the Great Depression and in a remote location, such that many athletes were [unable](https://history.fei.org/node/26) to afford the trip to the Olympics. 

- **Melbourne, 1956:** Attendance dipped due to several boycotts: Iraq, Egypt, and Lebanon did not participate due to the involvement of France and Britain in the [Suez Crisis](https://en.wikipedia.org/wiki/Suez_Crisis); the Netherlands, Spain, Switzerland, and Cambodia did not participate due to the Soviet Union's beat down of the [Hungarian Revolution](https://en.wikipedia.org/wiki/Hungarian_Revolution_of_1956); and China did not participate in protest of the IOC's [recognition](https://en.wikipedia.org/wiki/Chinese_Taipei_at_the_Olympics) of Taiwan.   

- **Montreal, 1976:** Attendance dipped because [25 nations](https://www.nytimes.com/1976/07/18/archives/22-african-countries-boycott-opening-ceremony-of-olympic-games.html), mostly African, boycotted the Games in reponse to apartheid policies in South Africa. Attendance at the 1980 Winter Olympics in Lake Placid wasn't affected much since African nations have a limited presence at the Winter Games.

- **Moscow, 1980:** Attendance dipped because [66 nations](https://www.history.com/this-day-in-history/carter-announces-olympic-boycott), including the U.S., boycotted the Games in response to the Soviet invasion of Afghanistan. 

The growth levels off around the year 2000, at least for the Summer Games. The list of events and athletes cannot grow indefinitely, and the Summer Games may have reached a saturation point near the turn of the century, with around 300 events and 10,000 athletes. The Winter Games would seem to have more growing room, but ice and snow sports are not practical or popular in most nations, and that doesn't seem likely to change soon.

# The Art Competitions

The 'Art Competitions' were included in the Olympics from 1912 to 1948, and included events in 5 disciplines: Architecture, Scupting, Painting, Literature, and Music. Medals were awarded to artists just like any other Olympic competition. The ideal of including sport-inspired art alongside athletic competitions was always part of the [vision](http://www.slate.com/human-interest/2018/05/gay-kids-and-sports-how-pe-class-felt-as-though-it-revealed-my-gayness-to-my-classmates.html) that Pierre de Coubertin, founder of the modern Olympics, had for the Games. He envisioned the Olympics as a multi-cultural celebration that showcased the educational value of amateur athletics for young men (and absolutely not for [young women](https://www.sbs.com.au/topics/zela/article/2016/05/03/women-olympic-games-uninteresting-unaesthetic-incorrect)). 

In 1954, the IOC concluded that art should no longer be included in the Olympics. In light of the present-day view of the Olympics as a Mega-World-Sports-Championship showcasing the supermen and superwomen of the world, you might be thinking, "Well of course art shouldn't be in the Olympics, it isn't a sport!". On the other hand, if you are more of an artist, you might find yourself balking at the idea that art could ever be included in a gladiatorial spectacle like the Olympics that presumes to crown the "best" in every category.

So you might be surprised to learn that "insufficient sportiness" or "violating the spirit of art" had nothing to do with the IOC's decision. Rather, the IOC at the time was obsessed with the idea that Olympians should not be paid so much as a penny for their talents, and they determined that artists, who had a habit of selling their art after the Olympics, were not "amateurs". So artists were banished to the sidelines of the Olympics, and there they have remained. 

I find this to be a fascinating bit of history that is deserving of some space in this kernel, even if the Art Competitions make up a mere 1.3% of my data. Let's look at the number of events, nations, and artists over time.

## Numer of events, nations, and artists over time

```{r art_growth_over_time}
# Subset to Art Competitions and variables of interest
art <- data %>% 
  filter(Sport == "Art Competitions") %>%
  select(Name, Sex, Age, Team, NOC, Year, City, Event, Medal)

# Count Events, Nations, and Artists each year
counts_art <- art %>% filter(Team != "Unknown") %>%
  group_by(Year) %>%
  summarize(
    Events = length(unique(Event)),
    Nations = length(unique(Team)),
    Artists = length(unique(Name))
  )

# Create plots
p4 <- ggplot(counts_art, aes(x=Year, y=Events)) +
  geom_point(size=2) +
  geom_line() + xlab("")
p5 <- ggplot(counts_art, aes(x=Year, y=Nations)) +
  geom_point(size=2) +
  geom_line() + xlab("")
p6 <- ggplot(counts_art, aes(x=Year, y=Artists)) +
  geom_point(size=2) +
  geom_line()
grid.arrange(p4, p5, p6, ncol=1)
```

Over this period, the number of events, participating nations, and artists grew irregularly. There was a jump in the number of nations and athletes participating in 1924, and perhaps in response to this increased participation, the number of events jumped up in 1928. 

## Which countries won the most art medals?

```{r art_medals_total}
# count number of medals awarded to each Team
medal_counts_art <- art %>% filter(!is.na(Medal))%>%
  group_by(Team, Medal) %>%
  summarize(Count=length(Medal)) 

# order Team by total medal count
levs_art <- medal_counts_art %>%
  group_by(Team) %>%
  summarize(Total=sum(Count)) %>%
  arrange(Total) %>%
  select(Team)
medal_counts_art$Team <- factor(medal_counts_art$Team, levels=levs_art$Team)

# plot
ggplot(medal_counts_art, aes(x=Team, y=Count, fill=Medal)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values=c("gold1","gray70","gold4")) +
  ggtitle("Historical medal counts from Art Competitions") +
  theme(plot.title = element_text(hjust = 0.5))
```

Out of 50 nations that participated in the Art Competitions, fewer than half won a medal, and over a third of all medals were awarded to artists representing just three countries: Germany, France, and Italy.

It is remarkable that Germany won the most medals in the Art Competitions between 1912 and 1948, considering that Germany was not invited to participate in 3 of the 7 Olympics during this period (they were banned from the 1920, 1924, and 1948 Olympics due to post-war politics). However, Germany made up for these absences with an especially strong showing at the 1936 Berlin Olympics, a.k.a., the [Nazi Olympics](http://www.jewishvirtuallibrary.org/the-nazi-olympics-august-1936), in which they won 40% of the medals in the Art Competitions and 60% of all the Art Competition medals in the country's history. 

## Nazis crush the 1936 Art Competitions

```{r}
# count number of medals awarded to each Team at Nazi Olympics
medal_counts_art_nazis <- art %>% filter(Year==1936, !is.na(Medal))%>%
  group_by(Team, Medal) %>%
  summarize(Count=length(Medal)) 

# order Team by total medal count
levs_art_nazis <- medal_counts_art_nazis %>%
  group_by(Team) %>%
  summarize(Total=sum(Count)) %>%
  arrange(Total) %>%
  select(Team)
medal_counts_art_nazis$Team <- factor(medal_counts_art_nazis$Team, levels=levs_art_nazis$Team)

# plot
ggplot(medal_counts_art_nazis, aes(x=Team, y=Count, fill=Medal)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values=c("gold1","gray70","gold4")) +
  ggtitle("Nazi domination of Art Competitions at the 1936 Olympics") +
  theme(plot.title = element_text(hjust = 0.5))
```

Yikes! The unfortunate truth is that Nazi Germany managed to use the 1936 Olympics as a platform for pro-Nazi propoganda. This is a black mark on the history of the Olympics, since the International Olympic Committee supported Germany hosting the Games even though people around the world were ringing the alarm bells that the Nazis were racist. 

The worst part is, the Nazis put on the best Olympics show ever. They even invented rituals such as the torch relay that we still include in the Olympics today. Oops... 

# Women in the Olympics

The founder of the modern Olympics, Pierre de Coubertin, held a number of opinions that are at odds with the contemporary "Olympic movement". Perhaps most famously, he strongly disapproved of [women](https://www.sbs.com.au/topics/zela/article/2016/05/03/women-olympic-games-uninteresting-unaesthetic-incorrect) competing in the Olympics, calling the idea "impractical, uninteresting, unaesthetic, and incorrect". 

Coubertin was the founder and first long-term president of the IOC (1896-1925), however he was not the last IOC president to oppose the inclusion of women in the Olympics. Avery Brundage, the American president of the IOC from 1952 to 1972, is perhaps most imfamous for being a likely Nazi sympathizer, but he also expressed [doubts](https://www.independent.com/news/2013/jan/03/he-demanded-olympics-purity-not-his-own/) that women should participate in the Olympics, and argued that certain sports were simply too strenuous for women, such as the shot put or long distance runs. 

Despite resistance from many directions, women have turned up to compete in every Olympic Games aside from the first in Athens, 1896. Here, I investigate historical trends in women's participation in the Olympics: how many there are, where they come from, and which ones find their way to the podium.

For these plots, I exclude the non-athletic Art Competitions and I combine data from Summer and Winter Games into "Olympiads", which refer to each 4 year period that includes one Summer and one Winter Games. Let's compare the growth of male and female participants over time. 

## Number of men and women over time

```{r genders_over_time}
# Exclude art competitions from data (I won't use them again in the kernel)
data <- data %>% filter(Sport != "Art Competitions")

# Recode year of Winter Games after 1992 to match the next Summer Games
# Thus, "Year" now applies to the Olympiad in which each Olympics occurred 
original <- c(1994,1998,2002,2006,2010,2014)
new <- c(1996,2000,2004,2008,2012,2016)
for (i in 1:length(original)) {
  data$Year <- gsub(original[i], new[i], data$Year)
}
data$Year <- as.integer(data$Year)

# Table counting number of athletes by Year and Sex
counts_sex <- data %>% group_by(Year, Sex) %>%
  summarize(Athletes = length(unique(ID)))
counts_sex$Year <- as.integer(counts_sex$Year)

# Plot number of male/female athletes vs time
ggplot(counts_sex, aes(x=Year, y=Athletes, group=Sex, color=Sex)) +
  geom_point(size=2) +
  geom_line()  +
  scale_color_manual(values=c("darkblue","red")) +
  labs(title = "Number of male and female Olympians over time") +
  theme(plot.title = element_text(hjust = 0.5))
```

Growth in the number of female athletes largely mirrored growth in the number of male athletes up until 1996, when growth in the number of male athletes leveled off at ~8000, while the number of female athletes continued to grow at a high rate. The participation of female athletes reached its highest point during the most recent Olympiad (Sochi 2014 and Rio 2016), in which slightly more than 44% of Olympians were women. 

But not all nations have invested equally in their female athletes: some have embraced the opportunity to win more medals in women's events, while others have been slow to include women on their Olympic teams. The following chart shows the number of female athletes versus the number of male athletes from 5 select Olympic Games (1936, 1956, 1976, 1996, and 2016), with each data point representing a National Olympic Committee (NOC) and separate best-fit regression lines for each of the 5 Games. Only NOCs represented by at least 50 athletes are included in the plot and regression line fitting. The dashed line represents the ideal of NOCs sending teams comprised of 50% women.  

## Number of women relative to men across countries

```{r women_vs_men_across_NOCs}
# Count M/F/Total per country per Olympics 
# Keep only country-years with at least 30 athletes
counts_NOC <- data %>% filter(Year %in% c(1936,1956,1976,1996,2016)) %>%
  group_by(Year, NOC, Sex) %>%
  summarize(Count = length(unique(ID))) %>%
  spread(Sex, Count) %>%
  mutate(Total = sum(M,F,na.rm=T)) %>%
  filter(Total > 49)
names(counts_NOC)[3:4] <- c("Male","Female")
counts_NOC$Male[is.na(counts_NOC$Male)] <- 0
counts_NOC$Female[is.na(counts_NOC$Female)] <- 0
counts_NOC$Year <- as.factor(counts_NOC$Year)

# Plot female vs. male athletes by NOC / Year
ggplot(counts_NOC, aes(x=Male, y=Female, group=Year, color=Year)) +
  geom_point(alpha=0.6) +
  geom_abline(intercept=0, slope=1, linetype="dashed") +
  geom_smooth(method="lm", se=FALSE) +
  labs(title = "Female vs. Male Olympians from participating NOCs") +
  theme(plot.title = element_text(hjust = 0.5)) +
  guides(color=guide_legend(reverse=TRUE))
```

The chart shows that although there wasn't much change from 1936 to 1956, there was dramatic improvement in female participation from 1956 to 2016. In 1996 and 2016, some NOCs even sent a majority of female athletes to the Games (these are represented by points above the dashed line). 

So which NOCs are leading the way for gender equality in the Olympics? The following charts rank nations by the proportion of female athletes on their Olympic Teams. In addition to showing the proportion of female athletes on each team, I show the proportion of each nations' medals that were won by females. I highlight data from 3 Olympiads: 1936 (Garmisch-Partenkirchen and Berlin), 1976 (Innsbruck and Montreal), and 2016 (Sochi and Rio). Like the previous chart, an NOC must have sent at least 50 athletes to the Games to be included. 

## Proportion of women on Olympic teams: 1936

```{r proportion_women_1936}
# Proportions of athletes/medals won by women from select NOCs/Years
props <- data %>% filter(Year %in% c(1936,1976,2016)) %>%
  group_by(Year, NOC, Sex) %>%
  summarize(Athletes = length(unique(ID)),
            Medals = sum(!is.na(Medal))) 
props <- dcast(setDT(props), 
               Year + NOC ~ Sex, 
               fun.aggregate = sum, 
               value.var = c("Athletes","Medals"))
props <- props %>% 
  mutate(Prop_F_athletes = Athletes_F/(Athletes_F + Athletes_M),
         Prop_F_medals = Medals_F/(Medals_F + Medals_M)) %>%
  filter(Athletes_F + Athletes_M > 49)
props$Prop_F_medals[props$Medals_M + props$Medals_F == 0] <- NA

# Data for 1936 only
props_1936 <- props %>% 
  filter(Year == 1936) %>%
  gather(Prop_F_athletes, Prop_F_medals, key="type", value="value")
levs <- props_1936 %>% 
  filter(type == "Prop_F_athletes") %>%
  arrange(value) %>% select(NOC)
props_1936$NOC <- factor(props_1936$NOC, levels=c(levs$NOC))

# Plot 1936
ggplot(props_1936, aes(x=value, y=NOC, color=type)) +
  geom_point(na.rm=FALSE, alpha=0.8) +
  scale_color_manual(name="",
                     values=c("black","goldenrod"),
                     labels=c("Athletes","Medals")) +
  labs(title="1936 Olympics (Garmisch-Partenkirchen and Berlin)", x="Proportion female") +
  theme(plot.title = element_text(hjust = 0.5)) +
  xlim(0,1)
```

Just 26 countries met the cutoff of sending at least 50 athletes to the 1936 Olympics. Canada lead the way with a 20% female Olympic team, followed by Great Britain with 19%. All other teams sent fewer than 15% women.

In terms of raw medal counts, the women of Nazi Germany dominated the 1936 Olympics, beating the second place the U.S by a comfortable margin.

## Medal counts for women of different nations: 1936

```{r medals_women_1936}
# Count number of medals awarded to each NOC at 1936 Olympics
counts_1936 <- data %>% filter(Year==1936, !is.na(Medal), Sex=="F") %>%
  group_by(NOC, Medal) %>%
  summarize(Count=length(Medal)) 

# Order NOC by total medal count
levs_1936 <- counts_1936 %>%
  group_by(NOC) %>%
  summarize(Total=sum(Count)) %>%
  arrange(Total) %>%
  select(NOC)
counts_1936$NOC <- factor(counts_1936$NOC, levels=levs_1936$NOC)

# Plot 1936
ggplot(counts_1936, aes(x=NOC, y=Count, fill=Medal)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values=c("gold1","gray70","gold4")) +
  ggtitle("Medal counts for women at the 1936 Olympics") +
  theme(plot.title = element_text(hjust = 0.5))
```

Female participation was much higher at the 1976 Olympics, with 12 teams bringing at least 25% women.

## Proportion of women on Olympic teams: 1976

```{r proportion_women_1976}
# Data for 1976 only
props_1976 <- props %>% 
  filter(Year == 1976) %>%
  gather(Prop_F_athletes, Prop_F_medals, key="type", value="value")
levs <- props_1976 %>% 
  filter(type == "Prop_F_athletes") %>%
  arrange(value) %>% select(NOC)
props_1976$NOC <- factor(props_1976$NOC, levels=c(levs$NOC))

# Plot 1976
ggplot(props_1976, aes(x=value, y=NOC, color=type)) +
  geom_point(na.rm=FALSE, alpha=0.8) +
  scale_color_manual(name="",
                     values=c("black","goldenrod"),
                     labels=c("Athletes","Medals")) +
  labs(title="1976 Olympics (Innsbruck and Montreal)", x="Proportion female") +
  theme(plot.title = element_text(hjust = 0.5)) +
  xlim(0,1)
```

This time East Germany lead the way with 40% of their team being female, followed by the Netherlands (35%) and Canada (33%). The Cold War superpowers, the U.S.S.R. and U.S., also had a relatively large number of female competitors on their teams, with about 29% each.

The raw medal counts reflect the dramatically different state of global political power in 1976 compared to 1936. 

## Medal counts for women of different nations: 1976

```{r medals_women_1976}
# Count number of medals awarded to each NOC at 1976 Olympics
counts_1976 <- data %>% filter(Year==1976, !is.na(Medal), Sex=="F") %>%
  group_by(NOC, Medal) %>%
  summarize(Count=length(Medal)) 

# Order NOC by total medal count
levs_1976 <- counts_1976 %>%
  group_by(NOC) %>%
  summarize(Total=sum(Count)) %>%
  arrange(Total) %>%
  select(NOC)
counts_1976$NOC <- factor(counts_1976$NOC, levels=levs_1976$NOC)

# Plot 1976
ggplot(counts_1976, aes(x=NOC, y=Count, fill=Medal)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values=c("gold1","gray70","gold4")) +
  ggtitle("Medal counts for women at the 1976 Olympics") +
  theme(plot.title = element_text(hjust = 0.5))
```

Whereas the women of Nazi Germany dominated the 1936 Olympics, the Soviet Union (URS) and East Germany (GDR) dominated the 1976 Olympics. The U.S. trailed East Germany and the Soviets by a large margin, and no other countries came close. 

Forty years later, participation of women in the Olympics surged.

## Proportion of women on Olympic teams: 2016

```{r proportion_women_2016, fig.height=10, fig.width=8.5}
# Data for 2014/2016 only
props_2016 <- props %>% 
  filter(Year == 2016) %>%
  gather(Prop_F_athletes, Prop_F_medals, key="type", value="value")
levs <- props_2016 %>% 
  filter(type == "Prop_F_athletes") %>%
  arrange(value) %>% select(NOC)
props_2016$NOC <- factor(props_2016$NOC, levels=c(levs$NOC))

# Plot 2014/2016
ggplot(props_2016, aes(x=value, y=NOC, color=type)) +
  geom_point(na.rm=FALSE, alpha=0.8) +
  scale_color_manual(name="",
                     values=c("black","goldenrod"),
                     labels=c("Athletes","Medals")) +
  labs(title="2014/2016 Olympics (Sochi and Rio)", 
       x="Proportion female") +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.y = element_text(size=6)) +
  xlim(0,1)
```

In comparison to 1976, in which not a single Olympic team was comprised of 50% women, the 2014/2016 Olympics included 15 teams that were at least 50% female, lead by China (64%), Romania (58%), and the Ukraine (57%). A few countries won 100% of their medals in women's events: Taiwan (5 medals in weightlifting and archery), India (2 medals in wrestling and badminton), Bulgaria (7 medals in the high jump, rhythmic gymnastics, and wrestling), and Portugal (1 medal in judo). 

Once again, total medal counts in the women's events reflect changing global power dynamics, with the U.S. dominating the medal count by a large margin. The women of Russia, Canada, Germany, China, and Great Britain formed an impressive but second class tier of female athletes. 

## Medal counts for women of different nations: 2016

```{r medals_women_2016, fig.height=8, fig.width=6}
# Count number of medals awarded to each NOC at 2014/2016 Olympics
counts_2016 <- data %>% filter(Year==2016, !is.na(Medal), Sex=="F") %>%
  group_by(NOC, Medal) %>%
  summarize(Count=length(Medal)) 

# Order NOC by total medal count
levs_2016 <- counts_2016 %>%
  group_by(NOC) %>%
  summarize(Total=sum(Count)) %>%
  arrange(Total) %>%
  select(NOC)
counts_2016$NOC <- factor(counts_2016$NOC, levels=levs_2016$NOC)

# Plot 2014/2016
ggplot(counts_2016, aes(x=NOC, y=Count, fill=Medal)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values=c("gold1","gray70","gold4")) +
  ggtitle("Medal counts for women at the 2014/2016 Olympics") +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.y = element_text(size=6))
```

These charts demonstrate that women's participation in the Olympics has grown dramatically over the past century, although equal participation has not yet been achieved. The Olympics will undoubtedly continue to be an important event for women's athletics, since for better or worse, nationalism seems to inspire people of diverse nations to care about women's athletics at least for the brief duration of the Games. In turn, the opportunity for international glory has the potential to motivate governments to invest in women's athletics even when a self-sustaining model for professional women's athletics is lacking.

# Geographic representation

Next let's look at how the number of athletes coming from different countries has changed over time. I will focus on three Summer Olympics, separated by 44 years each.

- Amsterdam 1928
- Munich 1972
- Rio 2016

I use chloropleth maps to visualize the geographic distribution of athletes at each Games.

## Amsterdam 1928

```{r chloropleth_1928, fig.width=10, fig.height=6}
# Load data file matching NOCs with mao regions (countries)
noc <- read_csv("../input/noc_regions.csv",
                col_types = cols(
                  NOC = col_character(),
                  region = col_character()
                ))

# Add regions to data and remove missing points
data_regions <- data %>% 
  left_join(noc,by="NOC") %>%
  filter(!is.na(region))

# Subset to Games of interest and count athletes from each country
amsterdam <- data_regions %>% 
  filter(Games == "1928 Summer") %>%
  group_by(region) %>%
  summarize(Amsterdam = length(unique(ID)))
munich <- data_regions %>% 
  filter(Games == "1972 Summer") %>%
  group_by(region) %>%
  summarize(Munich = length(unique(ID)))
rio <- data_regions %>% 
  filter(Games == "2016 Summer") %>%
  group_by(region) %>%
  summarize(Rio = length(unique(ID)))

# Create data for mapping
world <- map_data("world")
mapdat <- tibble(region=unique(world$region))
mapdat <- mapdat %>% 
  left_join(amsterdam, by="region") %>%
  left_join(munich, by="region") %>%
  left_join(rio, by="region")
mapdat$Amsterdam[is.na(mapdat$Amsterdam)] <- 0
mapdat$Munich[is.na(mapdat$Munich)] <- 0
mapdat$Rio[is.na(mapdat$Rio)] <- 0
world <- left_join(world, mapdat, by="region")

# Plot: Amsterdam 1928
ggplot(world, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = Amsterdam)) +
  labs(title = "Amsterdam 1928",
       x = NULL, y=NULL) +
  theme(axis.ticks = element_blank(),
        axis.text = element_blank(),
        panel.background = element_rect(fill = "navy"),
        plot.title = element_text(hjust = 0.5)) +
  guides(fill=guide_colourbar(title="Athletes")) +
  scale_fill_gradient(low="white",high="red")
```

## Munich 1972

```{r chloropleth_1972, fig.width=10, fig.height=6}
# Plot: Munich 1972
ggplot(world, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = Munich)) +
  labs(title = "Munich 1972",
       x = NULL, y = NULL) +
  theme(axis.ticks = element_blank(),
        axis.text = element_blank(),
        panel.background = element_rect(fill = "navy"),
        plot.title = element_text(hjust = 0.5)) +
  guides(fill=guide_colourbar(title="Athletes")) +
  scale_fill_gradient2(low = "white", high = "red")
```

## Rio 2016

```{r chloropleth_2016, fig.width=10, fig.height=6}
# Plot:  Rio 2016
ggplot(world, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = Rio)) +
  labs(title = "Rio 2016",
       x = NULL, y = NULL) +
  theme(axis.ticks = element_blank(),
        axis.text = element_blank(),
        panel.background = element_rect(fill = "navy"),
        plot.title = element_text(hjust = 0.5)) +
  guides(fill=guide_colourbar(title="Athletes")) +
  scale_fill_gradient2(low="white",high = "red")
```

It is clear from these plots that geographic representation in the Olympics has expanded over time, although several parts of the world are still severely underrepresented. These include most of Africa, Southeast Asia, the Middle East, and much of South America (although Brazil made a strong showing at the Rio Olympics). 

# Height and weight of athletes

The motto for the Olympics is "Citius, Altius, Fortius", which means "Faster, Higher, Stronger" in Latin. Indeed, as illustrated by the long history of record-breaking performances at the Olympics, athletes at every Olympics seem to be faster and stronger than the one before. Let's explore a correlary of this phenomenon: historical trends in the heights and weights of Olympic athletes.

First, let's check data completeness from each Olympiad, since it is likely that data on athletes' height and weight was rarely recorded from early Games. 

## Data completeness

```{r}
# Check data availability
data %>% group_by(Year, Sex) %>%
  summarize(Present = length(unique(ID[which(!is.na(Height) & !is.na(Weight))])),
            Total = length(unique(ID))) %>%
  mutate(Proportion = Present/Total) %>%
  ggplot(aes(x=Year, y=Proportion, group=Sex, color=Sex)) +
  geom_point() +
  geom_line() +
  scale_color_manual(values=c("darkblue","red"))  +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(title="Height/Weight data completeness from each Olympiad")
```

There was a dramatic increase in data completeness starting in 1960, reaching 86% for women and 90% for men. For all of the Games after this point, data completeness remained above 85% except for 1992, where completeness dips down to 80% for unclear reasons. In light of this, I limited the remainder of this data exploration to Games from 1960 onward, which includes a total of 15 Olympiads spread over a 56 year period.  

```{r}
# Remove missing Height/Weight data and limit to years from 1960 onward
data <- data %>% filter(!is.na(Height), !is.na(Weight), Year > 1959) 
```

The next two plots show trends in the heights and weights of Olympic athletes over time, with the data grouped by sex.

## Athlete height over time

```{r}
data %>% ggplot(aes(x=as.factor(Year), y=Height, fill=Sex)) +
  geom_boxplot(alpha=0.75) +
  xlab("Olympiad Year") + ylab("Height (cm)") +
  scale_fill_manual(values=c("blue","red"))
```

## Athlete weight over time

```{r}
data %>% ggplot(aes(x=as.factor(Year), y=Weight, fill=Sex)) +
  geom_boxplot(alpha=0.75) +
  xlab("Olympiad Year") + ylab("Weight (kg)") +
  scale_fill_manual(values=c("blue","red"))
```

These plots show that for both men and women, height and weight has increased gradually over the history of the Games. However, these plots could be hiding important variation since different body types are favored in different events. To explore this possibility, we must dive deeper into the data and consider trends in size separately for different events. However, since events have been added and removed from the Games throughout history, we must first identify a subset of events that have appeared consistently in the Olympics from 1960 to 2016.

Out of 489 events that appeared at least once in the Olympics since 1960, only 136 were included in every Olympiad. These include events for both men and women in alpine skiing, athletics, canoeing, diving, equestrian, fencing, figure skating, gymnastics, speed skating, and swimming, as well as events for men only in basketball, biathlon, boxing, crosscountry skiing, cycling, football, field hockey, ice hockey, pentathlon, rowing, ski jumping, water polo, weightlifting, and wrestling.

```{r}
# Identify events present in all 15 Games
events <- data[data$Year==1960,"Event"] %>% unique %>% .$Event # 177 in 1960
years <- data$Year %>% unique %>% sort %>% tail(-1)
for (i in 1:length(years)) {
  nxt <- data[data$Year==years[i],"Event"] %>% unique %>% .$Event
  events <- intersect(events, nxt)
}

# Subset data to only these events
data <- data %>% filter(Event %in% events)

# Get list of sports matching events
sports_events <- data %>% select(Sport, Event) %>% unique
```

This is a lot of events to consider, but we can reduce the list a bit. First, we can eliminate events based on weight classes (wrestling, weightlifting, and boxing), since the size of athletes in these events are restricted and the changes over time primarily reflect [shifting definitions](https://www.sports-reference.com/olympics/summer/2000/WRE/) of the weight classes. Second, we can eliminate events that include both men and women, including all the equestrian events and pairs figure skating. This leaves 108 events to consider. 

To charaterize historical trends in size for different events, I fit separate linear regressions for Height ~ Year and Weight ~ Year for athletes in each event, and saved the estimated regression slopes. By plotting the estimated regression slopes for height against the estimated regression slopes for weight across different events, we can identify events in which the size of athletes have changed the most. Importantly, the quadrant of the plot in which the point falls indicates the type of size change for each event:

- Upper left quadrant: athletes have gotten shorter and heavier
- Upper right quadrant: athletes have gotten taller and heavier
- Lower right quadrant: athletes have gotten taller and lighter
- Lower left quadrant: athletes have gotten shorter and lighter

Here is an interactive plot for men's events. 

## Change in height vs change in weight over time across men's sports

```{r size_across_events_men}
# Eliminate wrestling, weightlifting, and boxing
sports_events <- sports_events %>% 
  filter(!Sport %in% c("Wrestling","Weightlifting","Boxing","Equestrianism")) %>%
  filter(!Event %in% c("Figure Skating Mixed Pairs")) %>%
  arrange(Sport)

# Add column for men/women/mixed
sports_events$Sex <- ifelse(grepl("Women",sports_events$Event),"Women","Men")

# Loop through events and fit regressions
s.height <- s.weight <- c()
for (i in 1:nrow(sports_events)) {
  temp <- data %>% filter(Event == sports_events$Event[i])
  lm.height <- lm(Height ~ Year, data=temp)
  lm.weight <- lm(Weight ~ Year, data=temp)
  s.height[i] <- lm.height$coefficients["Year"]
  s.weight[i] <- lm.weight$coefficients["Year"]
}
slopes <- tibble(Sport = sports_events$Sport, 
                 Event = sports_events$Event,
                 Sex = sports_events$Sex,
                 Height = s.height,
                 Weight = s.weight)

# Multiple slopes by 56 since 56 years passed between 1960 to 2016
slopes$Height <- round(slopes$Height*56,1)
slopes$Weight <- round(slopes$Weight*56,1)

# Plot regression slopes of weight ~ height for men
g2.m <- ggplot(slopes[slopes$Sex=="Men",], aes(x=Height, y=Weight, color=Sport, label=Event)) +
  geom_point(alpha=0.75) +
  geom_vline(xintercept = 0) +
  geom_hline(yintercept = 0) +
  labs(title="Temporal trends in men's size in different events",
       x="Height (cm)",
       y="Weight (kg)")  +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position="none")
ggplotly(g2.m)
```

The vast majority of points fall in the upper right quadrant, indicating that the most common trend is for athletes to get both taller and heavier. This agrees with the boxplots from earlier in this post, which showed that the average height and weight for Olympic athletes has increased over time. The increase in size has been most extreme for points near the upper right corner of the plot, including basketball, ice hockey, water polo, downhill skiing, and rowing. Swimmers appear near the lower right portion of this quadrant, indicating that they have increased disproportionately in height relative to weight.

While most events are characterized by larger athletes over time, quite a few points fall in the lower left quadrant, indicating that for some events, the trend has been for athletes to get shorter and lighter. The light blue cluster of points in the lower left part of the chart represent gymnasts. Likewise, long distance runners and walkers, platform divers, and figure skaters have also tended to get smaller over time. 

Virtually no points fall in the upper left quadrant, indicating that there are no events for which athletes have simultaneously gotten shorter and heavier. Only a few events fall in lower right quadrant, representing events for which athletes have gotten simultaneously taller and lighter. Ski jumping is an outlier in this quadrant: since 1960, ski jumpers have gotten 5.2 cm taller but 10.8 kg lighter on average. The other events in which athletes have gotten taller but slightly lighter include several long distance running events and the high jump. 

Here is the same plot for women's events.

## Change in height vs change in weight over time across women's sports

```{r size_across_events_women}
# Plot regression slopes of weight ~ height for women
g2.f <- ggplot(slopes[slopes$Sex=="Women",], aes(x=Height, y=Weight, color=Sport, label=Event)) +
  geom_point(alpha=0.75) +
  geom_vline(xintercept = 0) +
  geom_hline(yintercept = 0) +
  labs(title="Temporal trends in women's size in different events",
       x="Height (cm)",
       y="Weight (kg)")  +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position="none")
ggplotly(g2.f)
```

Overall, results for the women's events are similar to the men's events. Although women's basketball, ice hockey, and water polo are missing from the data due to their absence from at least some of the Game since 1960, the other sports appearing in the extreme upper right quadrant are the same: alpine skiing, swimming, the shot put and the discus throw. Like the men, female gymnasts and platform divers appear in the lower left quadrant, indicating that they too have decreased in both height and weight. No events appear in the upper left quadrant, and scarcely any fall in the lower right quadrant. The one point that falls clearly in the lower right quadrant corresponds to the high jump, in which women mirror the men in becoming substantially taller and slightly lighter. 

Taken together, these charts highlight that the bodies of Olympic athletes have become increasingly extreme over time. While the trend is for athletes in most events to become taller and heavier, there are also a handful of events in which athletes have become smaller (e.g., gymnastics) or simultaneously taller and lighter (e.g., ski jumping). 

# Summary of key findings

- The number of athletes, events, and nations has grown dramatically since 1896, but growth leveled off around 2000 for the Summer Games.
- The Art Competitions were included from 1912 to 1948, and were dominated by Germany, France, and Italy. Nazi Germany was especially dominant in the 1936 Games.
- Geographic representation in the Games has grown since 1896, although Africa, Southeast Asia, the Middle East, and South America are still very under-represented.
- Female participation increased dramatically, and this trend started during the Cold War.
- Nazi women dominated the medals in 1936, East German and Soviet women dominated in 1976, and American women dominted in 2016. 
- The size of Olympians have become more extreme over time. In most sports this means taller and heavier, but in a few sports such as gymnastics, athletes have become smaller.