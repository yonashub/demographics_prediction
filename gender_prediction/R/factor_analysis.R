library(psych)
library(reshape)

# get vars with high multi-colinearity
data = read.csv(file = "cleaned_south_asian_data_a2_c2.csv.standard_scaled", header = TRUE, sep = ",")
correlations = cor(data)
subset(melt(correlations), value > .99 & value != 1)

# function to perform simple logistic regression on data, splits to train and test and report test error
perform_logistic = function(data, cutoff=0.5) {
  data_size = nrow(data)
  # 20% test
  test_size = floor(0.20 * data_size)
  test_indices = sample(seq(data_size), size = test_size)
  
  test_data = data[test_indices,]
  unbalanced_train_data = data[-test_indices,]
  # now need to balance train data
  size_per_class = min(sum(unbalanced_train_data$labels == 0), sum(unbalanced_train_data$labels == 1))
  ones = unbalanced_train_data[unbalanced_train_data$labels == 1,]
  zeros = unbalanced_train_data[unbalanced_train_data$labels == 0,]
  ones = ones[sample(nrow(ones), size_per_class), ]
  zeros = zeros[sample(nrow(zeros), size_per_class), ]
  train_data = rbind(ones, zeros)
  
  model = glm(labels ~ ., family=binomial(link='logit'), data = train_data)
  print(summary(model))
  test_predictions = predict.glm(model, newdata=test_data, type='response')
  test_predictions = ifelse(test_predictions > cutoff, 1, 0)
  
  accuracy = mean(test_predictions == test_data$labels)
  pos_precision = sum(test_predictions == 1 & test_data$labels == 1) / sum(test_predictions == 1)
  pos_recall = sum(test_predictions == 1 & test_data$labels == 1) / sum(test_data$labels == 1)
  pos_f_score = 2 * pos_precision * pos_recall / (pos_precision + pos_recall)

  neg_precision = sum(test_predictions == 0 & test_data$labels == 0) / sum(test_predictions == 0)
  neg_recall = sum(test_predictions == 0 & test_data$labels == 0) / sum(test_data$labels == 0)
  neg_f_score = 2 * neg_precision * neg_recall / (neg_precision + neg_recall)

  test_ones_frac = sum(test_data$labels == 1) / length(test_data$labels)
  test_zeros_frac = sum(test_data$labels == 0) / length(test_data$labels)
  print(paste('Accuracy', accuracy))
  print(paste('Positive Precision', pos_precision))
  print(paste('Positive Recall', pos_recall))
  print(paste('Positive F-score', pos_f_score))
  
  print(paste('Negative Precision', neg_precision))
  print(paste('Negative Recall', neg_recall))
  print(paste('Negative F-score', neg_f_score))
  
  print(paste('Weighted Precision', weighted.mean(c(pos_precision, neg_precision), c(test_ones_frac, test_zeros_frac)) ))
  print(paste('Weighted Recall', weighted.mean(c(pos_recall, neg_recall), c(test_ones_frac, test_zeros_frac)) ))
  print(paste('Weighted F-Score', weighted.mean(c(pos_f_score, neg_f_score), c(test_ones_frac, test_zeros_frac)) ))
}

##################################
# SA DATA 
setwd(dir = "~/research/gender_prediction/data/extended_indicators/south_asian/")

# label column with skewness kurtosis
label_column = 1257
# label column without skewness kurtosis
label_column_without_sk = 1005
# label column without median skewness kurtosis
label_column_without_msk = 879
# label column with only allweek_allday
label_column = 145

data = read.csv(file = "cleaned_south_asian_data_a2_c2.csv.standard_scaled", header = TRUE, sep = ",")
#data = read.csv(file = "cleaned_south_asian_data_a2_c2_without_skewness_kurtosis.csv.standard_scaled", header = TRUE, sep = ",")
#data = read.csv(file = "cleaned_south_asian_data_a2_c2_without_median_skewness_kurtosis.csv.standard_scaled", header = TRUE, sep = ",")
#data = read.csv(file = "cleaned_south_asian_data_a2_c2_allweek_allday.csv.standard_scaled", header = TRUE, sep = ",")
features = data[1:label_column]
labels = data[label_column+1]

# sample
#features = features[sample(nrow(features), 10000), ]

# scree plot of features, look for inflection or elbow point to use as the the number of factors
scree(features)
# the parallel rule:  eigenvalues from a data set prior to rotation are compared with those from a
# matrix of random values of the same dimensionality (p variables and n samples).
# The idea is that any eigenvalues below those generated by random chance are superfluous.
fa.parallel(features)
# Very simple structure: another way to determine the appropriate number of factors
vss(features)

# number of factos in cleaned_south_asian_data_a2_c2.csv.standard_scaled
num_factors = 125
# number of factos in cleaned_south_asian_data_a2_c2_without_skewness_kurtosis.csv.standard_scaled
num_factors_without_sk = 112
# number of factos in cleaned_south_asian_data_a2_c2_without_median_skewness_kurtosis.csv.standard_scaled
num_factors_without_msk = 105
# number of factos in cleaned_south_asian_data_a2_c2_allweek_allday.csv.standard_scaled
num_factors_allweek_allday = 27


fa.results = fa(features, nfactors = num_factors, rotate="oblimin", fm="minres", warning=TRUE, missing=TRUE, maxit=10000)
#fa.results = fa(features, nfactors = num_factors, rotate="quartimin", fm="minres", warning=TRUE, missing=TRUE, maxit=10000)
#fa.results = fa(features, nfactors = num_factors, rotate="oblimin", fm="pa", warning=TRUE, missing=TRUE, maxit=10000)
#fa.results = fa(features, nfactors = num_factors, rotate="varimax", fm="minres", warning=TRUE, missing=TRUE, maxit=2000)
#fa.results = fa(features, nfactors = num_factors, rotate="oblimin", fm="minres", warning=TRUE, missing=TRUE, maxit=10000, oblique.scores = TRUE)

# save or load factor analysis results
save(fa.results, file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_south_asian_data_a2_c2.csv.standard_scaled.fa_results")
save(fa.results, file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_south_asian_data_a2_c2_without_skewness_kurtosis.csv.standard_scaled.fa_results")
save(fa.results, file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_south_asian_data_a2_c2_without_median_skewness_kurtosis.csv.standard_scaled.fa_results")
save(fa.results, file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_south_asian_data_a2_c2_allweek_allday.csv.standard_scaled.fa_results")

load(file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_south_asian_data_a2_c2.csv.standard_scaled.fa_results")
load(file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_south_asian_data_a2_c2_without_skewness_kurtosis.csv.standard_scaled.fa_results")
load(file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_south_asian_data_a2_c2_without_median_skewness_kurtosis.csv.standard_scaled.fa_results")
load(file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_south_asian_data_a2_c2_allweek_allday.csv.standard_scaled.fa_results")

# Communalities tells us how much of the variance in each of the original variables is explained by the extracted factors
# Higher communalities are desirable.  If the communality for an original variable is less than 50%, it is a candidate for exclusion from the analysis because
# the factor solution contains less that half of the variance in the original variable. That variable should be just by itself.
which(fa.results$communality < 0.4)
loadings = fa.results$loadings
print(loadings, cut=0.01)
plot(fa.results)
fa.diagram(fa.results)


# scores from based on structure matrix (Simple correlation between factors and variables)
structure_scores = as.data.frame(fa.results$scores)
# scores based on the pattern matrix (Unique relationship between each factor and variable that takes into account the correlation between the factors)
# Note that if you set oblique.score = TRUE in fa(), you get oblique scores in fa.results$scores. The default is false which returns stucture based scores
oblique_scores = as.data.frame(as.matrix(features) %*% fa.results$loadings)

# get highest and lowest correlating factors with the labels. We will use the oblique scores since they are better suited for interpretation and
# the pattern matrix represents unique individual investment of the factor in a variable after taking correlations between factors into account
#sorted_correlations = sort(abs(cor(structure_scores, labels)), index.return=T, decreasing = TRUE)
sorted_correlations = sort(abs(cor(oblique_scores, labels)), index.return=T, decreasing = TRUE)

# print top correlating factors, their index (to be used as factor_num) in loadings matrix, and their name
num_factors_to_show = 10
head(sorted_correlations$x, num_factors_to_show)
head(sorted_correlations$ix, num_factors_to_show)
names(fa.results$loadings[1,])[head(sorted_correlations$ix, num_factors_to_show)]

tail(sorted_correlations$x, num_factors_to_show)
tail(sorted_correlations$ix, num_factors_to_show)
names(fa.results$loadings[1,])[tail(sorted_correlations$ix, num_factors_to_show)]

loading_threshold = 0.4
factor_num = 93  22  91  56 121  55 116  28 113  53  24  73 123 124  36  25 125  48  43  33   4  13   3 122  17  62  10  66   6  47
factor_num=13
factor_num=56
factor_num=3
sort(loadings[which(abs(loadings[,factor_num])> loading_threshold), factor_num], decreasing=TRUE)
factor_scores = oblique_scores[,factor_num]

# perform logistic regression using the factors
logistic_data = data.frame(factor_scores, labels)
names(logistic_data) = c("factor_scores", "labels")
perform_logistic(logistic_data)


# how many factors correspond to top features
sa_top_features = c("call_duration__allweek__day__call__mean__mean",
                    "call_duration__weekday__allday__call__median__mean",
                    "entropy_of_contacts__allweek__allday__call__mean",
                    "percent_initiated_interactions__allweek__allday__call__mean",
                    "call_duration__allweek__day__call__max__mean",
                    "call_duration__allweek__allday__call__max__mean",
                    "entropy_of_antennas__allweek__allday__mean",
                    "percent_initiated_interactions__weekday__allday__call__mean",
                    "percent_at_home__weekday__allday__mean",
                    "percent_at_home__weekend__day__mean",
                    "entropy_of_antennas__weekday__allday__mean",
                    "percent_initiated_interactions__allweek__night__call__mean",
                    "percent_initiated_interactions__weekend__night__call__mean",
                    "percent_at_home__weekday__day__mean",
                    "percent_at_home__weekend__day__std",
                    "percent_at_home__weekend__night__std",
                    "percent_at_home__weekend__allday__std",
                    "balance_of_contacts__allweek__night__text__max__mean",
                    "balance_of_contacts__allweek__allday__text__max__mean",
                    "percent_initiated_interactions__weekday__night__call__mean",
                    "balance_of_contacts__allweek__day__text__median__mean",
                    "balance_of_contacts__weekend__allday__text__max__mean",
                    "percent_initiated_conversations__allweek__day__callandtext__mean",
                    "balance_of_contacts__weekday__night__call__min__std",
                    "percent_nocturnal__weekend__allday__text__std")
loading_threshold = 0.4
sa_top_features_factors = c()
for (top_feature in sa_top_features) {
  # get the factors this feature belongs to
  feature_factors = names(which(abs(loadings[top_feature,])>loading_threshold))
  sa_top_features_factors = union(sa_top_features_factors, feature_factors)
  if (length(feature_factors) == 0) {
    print(paste("Warning: feature ", top_feature, " did not belong to any factor with loading threshold ", loading_threshold))
  }
  if (length(feature_factors) > 1) {
    print(paste("Warning: feature ", top_feature, " belongs to ", length(feature_factors), " factor with loading threshold ", loading_threshold))
  }
}
print(paste("Top ", length(sa_top_features), " in SA correspond to ", length(sa_top_features_factors), " factors"))



##################################
# EU DATA
setwd(dir = "~/research/gender_prediction/data/extended_indicators/european/")

# label column with skewness kurtosis
label_column = 1383
# label column without skewness kurtosis
label_column_without_sk = 1095
# label column without median skewness kurtosis
label_column_without_msk = 951 
# label column with only allweek_allday
label_column = 159

data = read.csv(file = "cleaned_european_data_a2_c2.csv.10%sample.standard_scaled", header = TRUE, sep = ",")
#data = read.csv(file = "cleaned_european_data_a2_c2_without_skewness_kurtosis.csv.10%sample.standard_scaled", header = TRUE, sep = ",")
#data = read.csv(file = "cleaned_european_data_a2_c2_without_median_skewness_kurtosis.csv.10%sample.standard_scaled", header = TRUE, sep = ",")
#data = read.csv(file = "cleaned_european_data_a2_c2_allweek_allday.csv.10%sample.standard_scaled", header = TRUE, sep = ",")
features = data[1:label_column]
labels = data[label_column+1]

# sample
#features = features[sample(nrow(features), 10000), ]

# scree plot of features, look for inflection or elbow point to use as the the number of factors
scree(features)
# the parallel rule:  eigenvalues from a data set prior to rotation are compared with those from a
# matrix of random values of the same dimensionality (p variables and n samples).
# The idea is that any eigenvalues below those generated by random chance are superfluous.
fa.parallel(features)
# Very simple structure: another way to determine the appropriate number of factors
vss(features)

# number of factos in cleaned_european_data_a2_c2.csv.10%sample.standard_scaled
num_factors = 145
# number of factos in cleaned_european_data_a2_c2_without_skewness_kurtosis.csv.10%sample.standard_scaled
num_factors_without_sk = 130
# number of factos in cleaned_european_data_a2_c2_without_median_skewness_kurtosis.csv.10%sample.standard_scaled
num_factors_without_msk = 120
# number of factos in cleaned_eurpean_data_a2_c2_allweek_allday.csv.10%sample.standard_scaled
num_factors_allweek_allday = 31

fa.results = fa(features, nfactors = num_factors, rotate="oblimin", fm="minres", warning=TRUE, missing=TRUE, maxit=10000)
#fa.results = fa(features, nfactors = num_factors, rotate="quartimin", fm="minres", warning=TRUE, missing=TRUE, maxit=10000)
#fa.results = fa(features, nfactors = num_factors, rotate="oblimin", fm="pa", warning=TRUE, missing=TRUE, maxit=10000)
#fa.results = fa(features, nfactors = num_factors, rotate="varimax", fm="minres", warning=TRUE, missing=TRUE, maxit=2000)
#fa.results = fa(features, nfactors = num_factors, rotate="oblimin", fm="minres", warning=TRUE, missing=TRUE, maxit=10000, oblique.scores = TRUE)

# save or load factor analysis results
save(fa.results, file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_european_data_a2_c2.csv.10%sample.standard_scaled.fa_results")
save(fa.results, file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_european_data_a2_c2_without_skewness_kurtosis.csv.10%sample.standard_scaled.fa_results")
save(fa.results, file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_european_data_a2_c2_without_median_skewness_kurtosis.csv.10%sample.standard_scaled.fa_results")
save(fa.results, file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_european_data_a2_c2_allweek_allday.csv.10%sample.standard_scaled.fa_results")

load(file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_european_data_a2_c2.csv.10%sample.standard_scaled.fa_results")
load(file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_european_data_a2_c2_without_skewness_kurtosis.csv.10%sample.standard_scaled.fa_results")
load(file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_european_data_a2_c2_without_median_skewness_kurtosis.csv.10%sample.standard_scaled.fa_results")
load(file = "~/research/gender_prediction/results/extended_indicators/factor_analysis/cleaned_european_data_a2_c2_allweek_allday.csv.10%sample.standard_scaled.fa_results")

# Communalities tells us how much of the variance in each of the original variables is explained by the extracted factors
# Higher communalities are desirable.  If the communality for an original variable is less than 50%, it is a candidate for exclusion from the analysis because
# the factor solution contains less that half of the variance in the original variable. That variable should be just by itself.
which(fa.results$communality < 0.4)
loadings = fa.results$loadings
print(loadings, cut=0.4)
plot(fa.results)
fa.diagram(fa.results)

# scores from based on structure matrix (Simple correlation between factors and variables) structure_scores = as.data.frame(fa.results$scores)
# scores based on the pattern matrix (Unique relationship between each factor and variable that takes into account the correlation between the factors)
# Note that if you set oblique.score = TRUE in fa(), you get oblique scores in fa.results$scores. The default is false which returns stucture based scores
oblique_scores = as.data.frame(as.matrix(features) %*% fa.results$loadings)

# get highest and lowest correlating factors with the labels. We will use the oblique scores since they are better suited for interpretation and
# the pattern matrix represents unique individual investment of the factor in a variable after taking correlations between factors into account
#sorted_correlations = sort(abs(cor(structure_scores, labels)), index.return=T, decreasing = TRUE)
sorted_correlations = sort(abs(cor(oblique_scores, labels)), index.return=T, decreasing = TRUE)

# print top correlating factors, their index (to be used as factor_num) in loadings matrix, and their name
num_factors_to_show = 10
head(sorted_correlations$x, num_factors_to_show)
head(sorted_correlations$ix, num_factors_to_show)
names(fa.results$loadings[1,])[head(sorted_correlations$ix, num_factors_to_show)]

tail(sorted_correlations$x, num_factors_to_show)
tail(sorted_correlations$ix, num_factors_to_show)
names(fa.results$loadings[1,])[tail(sorted_correlations$ix, num_factors_to_show)]

loading_threshold = 0.4
factor_num = 76
sort(loadings[which(abs(loadings[,factor_num])> loading_threshold), factor_num], decreasing=TRUE)
factor_scores = oblique_scores[,factor_num]

# perform logistic regression using the factors
logistic_data = data.frame(factor_scores, labels)
names(logistic_data) = c("factor_scores", "labels")
perform_logistic(logistic_data)


# how many factors correspond to top features
eu_top_features = c("entropy_of_contacts__weekday__day__text__mean",
                    "entropy_of_contacts__allweek__allday__call__mean",
                    "call_duration__allweek__allday__call__max__mean",
                    "entropy_of_antennas__allweek__allday__mean",
                    "entropy_of_contacts__allweek__allday__call__std",
                    "entropy_of_contacts__weekday__day__call__mean",
                    "percent_nocturnal__weekend__allday__call__mean",
                    "entropy_of_contacts__allweek__day__call__mean",
                    "percent_initiated_conversations__weekend__day__callandtext__mean",
                    "percent_initiated_conversations__allweek__night__callandtext__mean",
                    "call_duration__weekday__day__call__max__std",
                    "entropy_of_antennas__weekday__day__std",
                    "percent_initiated_interactions__weekday__day__call__mean",
                    "entropy_of_contacts__weekday__allday__call__mean",
                    "response_rate_text__weekday__day__callandtext__std",
                    "call_duration__weekend__day__call__max__std",
                    "response_delay_text__allweek__day__callandtext__max__mean",
                    "percent_pareto_durations__weekday__day__call__std",
                    "balance_of_contacts__weekend__night__text__max__mean",
                    "percent_nocturnal__weekend__allday__text__mean",
                    "balance_of_contacts__weekend__night__call__min__std",
                    "entropy_of_antennas__weekday__allday__mean",
                    "percent_pareto_durations__allweek__day__call__std",
                    "active_days__weekend__day__callandtext__mean",
                    "response_rate_text__weekend__day__callandtext__std")
                    
loading_threshold = 0.4
eu_top_features_factors = c()
for (top_feature in eu_top_features) {
  # get the factors this feature belongs to
  feature_factors = names(which(abs(loadings[top_feature,])>loading_threshold))
  eu_top_features_factors = union(eu_top_features_factors, feature_factors)
  if (length(feature_factors) == 0) {
    print(paste("Warning: feature ", top_feature, " did not belong to any factor with loading threshold ", loading_threshold))
  }
  if (length(feature_factors) > 1) {
    print(paste("Warning: feature ", top_feature, " belongs to ", length(feature_factors), " factor with loading threshold ", loading_threshold))
  }
}
print(paste("Top ", length(eu_top_features), " in EU correspond to ", length(eu_top_features_factors), " factors"))
