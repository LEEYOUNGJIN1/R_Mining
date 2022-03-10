## 3. Data Visualization with ggplot2

# https://r4ds.had.co.nz/data-visualisation.html

#######################################################
# tidyverse: ggplot2, purrr, tibble,  dplyr,          #
#            tidyr, stringr, readr, forcats           #
#######################################################

# install.packages("tidyverse") 
library(tidyverse)

# 01.데이터 불러오기
# p.100 설명

# 자동차 관련 데이터(내장 데이터) 
mpg

# 데이터 확인하기
view(mpg)
glimpse(mpg)
str(mpg)

# 02.그래프 그리기 (기본 함수 이용)
barplot(mpg$class) # 에러

# 기본 함수로 그래프를 그리려면 table을 이용해 데이터를 정리한 후에 사용해야 함
tb <- table(mpg$class)
tb
barplot(tb)

# 03.ggplot 사용
# p.107 그림 설명
# ggplot을 이용하면 데이터를 자동으로 생성
# (Statistical transformations)

# 빈도수 사용
ggplot(data = mpg, 
       mapping = aes(x = class)) + 
  geom_bar()

# 비율 사용
ggplot(data = mpg, 
       mapping = aes(x = class,
                     y = stat(prop), 
                     group = 1)) + 
  geom_bar()

# 04.ggplot 기본문법
# p.111 설명
# 설명: Help -> Cheatsheets -> “Data Visualization with ggplot2.”
# 1번과 2번 모두 사용가능하지만 1번을 이용
# geom_function()의 기능을 사용해야 됨
ggplot(data = mpg, 
       mapping = aes(x = displ, 
                     y = hwy)) + 
  geom_point()

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, 
                           y = hwy))

# 05.Aesthetic과 geom mappings 차이
# p.119 그림 설명
# aes는 변수에 매핑함
# geom은 플롯 전체에 매핑함 

# Aesthetic mappings
ggplot(data = mpg, 
       mapping = aes(x = displ, 
                     y = hwy, 
                     color=class)) +   # color = 변수명
  geom_point()


# geom mappings
ggplot(data = mpg, 
       mapping = aes(x = displ, 
                     y = hwy)) + 
  geom_point(color="blue")            # color = 속성


# Aesthetic mappings 옵션들
ggplot(data=mpg, 
       mapping=aes(x=displ,          # 변수명 매칭
                   y=hwy,            # 변수명 매칭
                   color=class,      # 변수명 매칭
                   size=hwy,         # 변수명 매칭
                   alpha=displ)) +  #alpha = 투명도
  geom_point()

# geom mappings 옵션들
ggplot(data=mpg, 
       mapping=aes(x=displ, 
                   y=hwy)) +
  geom_point(color="blue",          # 속성 매칭
             size=3,
             alpha=0.7)

# 06.Facet: 화면을 분리 
# 구분변수가 1개일 때
# facet_wrap ( ~ class)
ggplot(data=mpg, 
       mapping=aes(x=displ, 
                   y=hwy)) +
  geom_point() +
  facet_wrap(~ class, 
             nrow = 2) # nrow:가로, ncol: 세로
ggplot(data=mpg, 
       mapping=aes(x=displ, 
                   y=hwy)) +
  geom_point() +
  facet_wrap(~ class, 
             ncol = 2) # nrow:가로, ncol: 세로

# 구분변수가 2개일때
ggplot(data=mpg, 
       mapping=aes(x=displ, 
                   y=hwy)) +
  geom_point() +
  facet_wrap(cyl ~ class)

# 07.여러개 geom 함수 사용
# 여러 개 함수를 중복해서 사용 가능
ggplot(data = mpg,
       mapping = aes(x = displ, 
                     y = hwy)) + 
  geom_smooth() +
  geom_point()

# 변수에 매핑하기 위해서는 aes 사용
ggplot(data = mpg, 
       mapping = aes(x = displ, 
                     y = hwy)) + 
  geom_point(mapping = aes(color = class)) +
  geom_smooth()

# 08.Coordinate systems
# 수평 <-> 수직
ggplot(data = mpg, 
       mapping = aes(x = class, 
                     y = hwy)) + 
  geom_boxplot()

ggplot(data = mpg, 
       mapping = aes(x = class, 
                     y = hwy)) + 
  geom_boxplot() +
  coord_flip()





















