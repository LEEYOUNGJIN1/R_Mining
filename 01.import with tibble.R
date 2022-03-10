## 1.import

# https://r4ds.had.co.nz/tibbles.html

#######################################################
# tidyverse: ggplot2, purrr, tibble,  dplyr,          #
#            tidyr, stringr, readr, forcats           #
#######################################################

# p.43 설명

# install.packages("tidyverse") 
library(tidyverse)

# 01.내장 데이터 불러오기
# iris 데이터(내장 데이터)
# df로 저장되어 있음 
iris
view(iris)
str(iris)

# 행과 열 변수 호출
iris$Sepal.Length   # 데이터명$변수명
iris[5:10,1:3]      # [행번호, 열번호]

# 02.tibble형태로 변환
iris <- as_tibble(iris)

# 데이터 확인하기
glimpse(iris)
str(iris)

# 결과삭제
# 파일명 저장
# p.59 pipe 설명하기

# 출력 갯수 조정하기
iris %>%
  print(n=10, width=Inf)

# 행과 열 변수 호출
iris %>%
  .$Sepal.Length

iris %>%
  .[5:10,1:3]


# df로 변환
iris_df <- as.data.frame(iris)
str(iris_df)

# 03.외부 데이터 불러오기
# 참고자료로만 확인
# 기존 df 방식으로 불러오기
ist_df <- read.csv('./data/ist_num.csv', 
                   header = TRUE,
                   na.strings=".")

tb <- table(ist_df$t_group)
tb
barplot(tb)

ist_df$t_group <- factor(ist_df$t_group,
                         levels = c(1,2),
                         labels = c("A자동차","B자동차"))

# tible 형식으로 불러오기
# 숫자일 경우에는 숫자 -> factor로 처리
ist_n_tb <- read_csv('./data/ist_num.csv', 
                     col_names = TRUE,
                     na=".") # csv 데이터 읽어오기
str(ist_n_tb)

# 방법1
ist_n_tb <- ist_n_tb %>%
  mutate(t_group = factor(t_group, 
                          levels = c(1,2),
                          labels = c("A자동차",
                                     "B자동차")))
str(ist_n_tb)

# 방법2
ist_n_tb <- read_csv('./data/ist_num.csv', 
                     col_names = TRUE,
                     na=".") # csv 데이터 읽어오기
ist_n_tb$t_group <- ist_n_tb$t_group %>%
  factor() %>%
  recode("1" = "A자동차",
         "2" = "B자동차")
str(ist_n_tb)


# 한글 인코딩으로 처리하여 한글 불러오기
ist_f_tb <- read_csv('./data/ist_chr.csv', 
                     col_names = TRUE,
                     locale=locale('ko', encoding='euc-kr'),
                     na=".") %>% # csv 데이터 읽어오기
  mutate_if(is.character, as.factor)
str(ist_f_tb)




# 04.저장하기
write_csv(ist_f_tb, "./data/ist_df.csv")































