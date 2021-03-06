# https://www.tidymodels.org/start/models/
# 유니버설 은행 사례 Figure 9.9 ####
# 1.최기 모델(Basic Model)

#######################################################
# tidyverse: ggplot2, purrr, tibble  3.0.3,           #
#            dplyr, tidyr, stringr, readr, forcats    #
#                           
# tidymodels: broom, recipes, dials, rsample, infer,  #
#             tune, modeldata, workflows, parsnip,    #
#             yardstick                               #
#######################################################

# install.packages("tidyverse") 
# install.packages("tidymodels")
# install.packages("skimr")
# install.packages("naniar")
# install.packages("vip")
library(tidyverse)
library(tidymodels)
library(skimr)           # 데이터 요약(EDA)
library(vip)             # 중요한 변수 찾기



# p.9 ~ 12 설명
## 01.데이터 불러오기

bank_tb <- read_csv('UniversalBank.csv', 
                    col_names = TRUE,
                    locale=locale('ko', encoding='euc-kr'),
                    na=".") %>% # csv 데이터 읽어오기
  mutate_if(is.character, as.factor)

str(bank_tb)
head(bank_tb)





## 02.data 전처리

# 변수명 수정 (공란이 있을 경우에 변수명 수정)

bank_tb <- bank_tb %>%
  rename(c('Personal_Loan'= 'Personal Loan',
           'CD_Account' = 'CD Account',
           'Securities_Account' = 'Securities Account'))
str(bank_tb)
head(bank_tb)


# 범주형 변수(factor)로 인식하게 변환

bank_tb <- bank_tb %>%
  mutate(Personal_Loan = factor(Personal_Loan, 
                                levels = c(0,1),  
                                labels = c("No", "Yes"))) %>%
  mutate(Securities_Account = factor(Securities_Account, 
                                     levels = c(0,1),
                                     labels = c("No", "Yes"))) %>%
  mutate(CD_Account  = factor(CD_Account, 
                              levels = c(0,1),
                              labels = c("No", "Yes"))) %>%
  mutate(Online = factor(Online,
                         levels = c(0,1),
                         labels = c("No", "Yes"))) %>%
  mutate(CreditCard = factor(CreditCard,
                             levels = c(0,1),
                             labels = c("No", "Yes"))) %>%
  mutate(Education  = factor(Education ,
                             levels = c(1:3),
                             labels = c("Undergrad", 
                                        "Graduate", 
                                        "Professional")))
str(bank_tb)
head(bank_tb)

# 필요없는 변수제거: ID, 우편번호 제거
# recipe에서 제거할 수도 있음

bank_tb <- bank_tb %>%
  select(-c(ID, `ZIP Code`))  

str(bank_tb)
head(bank_tb)

## 03.데이터 탐색(EDA)

# 데이터 탐색: 범주형, 연속형 구분
# skimr::skim() - package명을 앞에 써서 구분
# 패키지를 여러개 사용할 경우에 이름이 같은 경우도 있어서
# 구분이 필요할 경우에 [패키지명::]을 사용

bank_tb %>%
  skimr::skim() 

bank_tb %>%
  group_by(Personal_Loan) %>%
  skimr::skim() 

# base accuracy
# yes 기준으로 0.096
bank_tb %>% 
  count(Personal_Loan) %>% 
  mutate(prop = n/sum(n))

## 04.훈련용, 테스트용 데이터 분할: partition
# 데이터 partition

set.seed(123) # 시드 고정 

bank_split <- 
  initial_split(bank_tb,prop=0.7,
                strata = Personal_Loan) # 결과변수 비율반영

bank_split

# training, test용 분리

train_data <- training(bank_split)
test_data  <- testing(bank_split)

# p.31 ~ 36 설명
## 05.Model 만들기
# Model 만들기
args(decision_tree)

tree_model <- 
  decision_tree() %>% 
  set_engine("rpart") %>% 
  set_mode("classification")

# recipe 만들기

tree_recipe <- 
  recipe(Personal_Loan ~ ., data = train_data) %>% 
  step_dummy(all_nominal(), -all_outcomes()) %>% 
  step_zv(all_predictors()) %>% 
  step_normalize(all_numeric())
# %>%
#   step_upsample(Personal_Loan) # 데이터 균형화
  
summary(tree_recipe)

## 06.workflow 만들기
tree_workflow <- 
  workflow() %>% 
  add_model(tree_model) %>% 
  add_recipe(tree_recipe)

tree_workflow

## 07.Model 훈련

# 훈련데이터로 모델 훈련하기

tree_train_fit <- 
  tree_workflow %>%
  fit(data = train_data)
  
# 모델 훈련 결과 확인

tree_train_fit %>%
  pull_workflow_fit()

## 08.훈련모델 검정

# 예측결과표 생성

tree_train_pred <- 
  predict(tree_train_fit, 
          train_data, 
          type = "prob") %>%
  bind_cols(predict(tree_train_fit, 
                    train_data)) %>% 
  bind_cols(train_data %>% 
              select(Personal_Loan)) %>%
  print()

# 정오분류표(confusion matrix) 만들기

tree_train_conf <-
  tree_train_pred  %>%
  conf_mat(truth = Personal_Loan, 
           estimate = .pred_class)

tree_train_conf

# f1: 재현율(Recall)(↑)과 정밀도(Precision)(↑)

tree_train_valid <- 
  tree_train_pred %>%
  f_meas(truth = Personal_Loan,
         estimate = .pred_class,
         event_level = "second")

# 재현율(Recall): 실제 Class 중에 잘 맞춘 것(=TPR=민감도)

tree_train_valid <- 
  tree_train_pred %>%                
  recall(truth = Personal_Loan, 
         estimate = .pred_class,
         event_level = "second")  %>% # Personal_Loan = 1 (yes)를 기준
  bind_rows(tree_train_valid)

# 정밀도(Precision): 예측 Class 중에 잘 맞춘 것

tree_train_valid <- 
  tree_train_pred %>%                
  precision(truth = Personal_Loan, 
            estimate = .pred_class,
            event_level = "second") %>%
  bind_rows(tree_train_valid)

# ACU(area under the curve): ROC 정확도

tree_train_valid <- 
  tree_train_pred %>%
  roc_auc(truth = Personal_Loan, 
          .pred_Yes,                 # 'estimate =' 없음
          event_level = "second")   %>%
  bind_rows(tree_train_valid)   

# 정확도 (Accuracy) : 클래스 0과 1 모두를 정확하게 분류

tree_train_valid <- 
  tree_train_pred %>%                
  accuracy(truth = Personal_Loan, 
           estimate = .pred_class)  %>%
  bind_rows(tree_train_valid)

tree_train_valid

# ROC 커브

train_auc <-
  tree_train_pred %>%
  roc_curve(truth = Personal_Loan, 
            estimate = .pred_Yes, 
            event_level = "second") %>% 
  mutate(model = "train_auc")

autoplot(train_auc)

# 중요변수 확인

tree_train_fit %>% 
  pull_workflow_fit() %>% 
  vip()

## 09.테스트 데이터 검정

# 구축된 모델에 test data로 검정
# last_fit 사용
# data: bank_split 사용

tree_test_fit <- 
  tree_workflow %>%
  last_fit(bank_split) 

tree_test_fit

# 예측결과 자동생성: collect_predictions() 

tree_test_pred <- 
  tree_test_fit %>%
  collect_predictions()

tree_test_pred

# 정오분류표(confusion matrix) 만들기

tree_test_conf <-
  tree_test_pred  %>%
  conf_mat(truth = Personal_Loan, 
           estimate = .pred_class)

tree_test_conf

# f1: 재현율(Recall)(↑)과 정밀도(Precision)(↑)

tree_test_valid <- 
  tree_test_pred %>%
  f_meas(truth = Personal_Loan,
         estimate = .pred_class,
         event_level = "second")

# 재현율(Recall): 실제 Class 중에 잘 맞춘 것(=TPR=민감도)

tree_test_valid <- 
  tree_test_pred %>%                
  recall(truth = Personal_Loan, 
         estimate = .pred_class,
         event_level = "second")  %>% # Personal_Loan = 1 (yes)를 기준
  bind_rows(tree_test_valid)

# 정밀도(Precision): 예측 Class 중에 잘 맞춘 것

tree_test_valid <- 
  tree_test_pred %>%                
  precision(truth = Personal_Loan, 
            estimate = .pred_class,
            event_level = "second") %>%
  bind_rows(tree_test_valid)

# 정확도 (Accuracy) : 클래스 0과 1 모두를 정확하게 분류
# ACU(area under the curve): ROC 정확도

tree_test_valid <-
  tree_test_fit %>%
  collect_metrics()  %>%
  bind_rows(tree_test_valid)

tree_test_valid

# ROC 커브

test_auc <-
  tree_test_pred %>%
  roc_curve(truth = Personal_Loan, 
            estimate = .pred_Yes, 
            event_level = "second") %>% 
  mutate(model = "test_auc")

autoplot(test_auc)

# 중요변수 확인

tree_test_fit %>%
  pluck(".workflow", 1) %>%   
  pull_workflow_fit() %>% 
  vip(num_features = 20)





## 10.train, test 검정결과 비교

# 정오분류표(confusion matrix) 비교

tree_train_conf
tree_test_conf

# 검정결과 비교

tree_train_valid
tree_test_valid

# ROC 커브 비교

bind_rows(train_auc, test_auc) %>% 
  ggplot(aes(x = 1 - specificity, 
             y = sensitivity, 
             color = model)) + 
  geom_path(lwd = 1.5) +
  geom_abline(lty = 3) + 
  coord_equal()




## 11.decision tree 만들기
# install.packages("rpart.plot")
library(rpart.plot)

rpart_fit <- 
  tree_train_fit %>% 
  pull_workflow_fit()


# 모형 1
rpart.plot(x = rpart_fit$fit,
           yesno = 2,
           type = 2, 
           extra = 1, 
           split.font = 1, 
           varlen = -10)

# 모형 2
prp(x = rpart_fit$fit, 
    type = 1, 
    extra = 1, 
    under = TRUE, 
    split.font = 1, 
    varlen = -10,
    box.col=ifelse(rpart_fit$fit$frame$var == "<leaf>", 'gray', 'white'))






