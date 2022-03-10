## 2. Data transformation with dplyr

# https://r4ds.had.co.nz/transform.html

#######################################################
# tidyverse: ggplot2, purrr, tibble,  dplyr,          #
#            tidyr, stringr, readr, forcats           #
#######################################################



# install.packages("tidyverse") 
library(tidyverse)

# install.packages("nycflights13") 
library(nycflights13)


# 01.데이터 불러오기
# p.74 설명

# 항공 관련 데이터(내장 데이터) 
flights

# 데이터 확인하기
view(flights)
glimpse(flights)
str(flights)




# 02.filter(): 원하는 행 선택
# p.84설명

# 1월 1일 선택
flights %>%
  filter(month==1, day==1)   # ‘==‘ 두 개 사용

# 11월 또는(|) 12월 선택
flights %>%
  filter(month == 11 | month == 12)




# 03.arrange(): 행 정렬
flights %>%
  arrange(month, desc(day)) # 내림차순(desc)

flights %>%
  arrange(desc(dep_delay))




# 04.select(): 원하는 변수선택 
# filter는 행, select는 열(변수)
flights %>%
  select(year, month, day)

flights %>%
  select(year:day)  # ‘:’ 연속으로 선택

flights %>%
  select(-(year:day)) #'-' 변수제거

flights %>%
  select(time_hour, air_time, everything()) # everything() 나머지 전부 




# 05.mutate(): 새로운 변수 생성
# 기존변수에 추가
flights %>%
  select(year:day, dep_delay, arr_delay, distance, air_time) %>%
  mutate(gain = dep_delay - arr_delay,
         hours = air_time / 60,
         gain_per_hour = gain / hours)

# 추가변수만 출력
flights %>%
  select(year:day, dep_delay, arr_delay, distance, air_time) %>%
  transmute(gain = dep_delay - arr_delay,
            hours = air_time / 60,
            gain_per_hour = gain / hours)




# 06.summarise(): 요약 - group_by와 같이 사용
flights %>%
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>%
  ungroup()




# 0.7전체 함수 조합 
filghts_new <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, 
         dest != "HNL") %>%
  arrange(desc(delay)) %>%
  filter(rank(delay) > 10) %>%
  ungroup()

filghts_new
