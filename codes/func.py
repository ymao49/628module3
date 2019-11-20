from sklearn.model_selection import StratifiedKFold, KFold, TimeSeriesSplit
from sklearn.metrics import classification_report, roc_auc_score, roc_curve
from sklearn import tree
from sklearn.preprocessing import LabelEncoder
import lightgbm as lgb
import logging
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import graphviz



logging.basicConfig(filename='log.txt',level=logging.DEBUG, format='%(asctime)s %(message)s')

class LGB():
        
    def lgb_train(X_data, y_data, X_test, params, features, fold_way='KFold', n_splits=5):
        if fold_way == 'KFold':
            folds = KFold(n_splits=n_splits, shuffle=True, random_state=2019)
        elif fold_way == 'StratifiedKFold':
            folds = StratifiedKFold(n_splits=n_splits, shuffle=True, random_state=2019)
        
        oof = np.zeros(len(X_data))
        getVal = np.zeros(len(X_data))
        predictions = np.zeros(len(X_test))
        feature_importance = pd.DataFrame()

        for fold_, (trn_idx, val_idx) in enumerate(folds.split(X_data.values, y_data)):
            xx_train, yy_train = X_data.iloc[trn_idx], y_data.iloc[trn_idx]
            xx_valid, yy_valid = X_data.iloc[val_idx], y_data.iloc[val_idx]
            print("Fold idx: {}".format(fold_ + 1))
            trn_data = lgb.Dataset(xx_train, label=yy_train)
            val_data = lgb.Dataset(xx_valid, label=yy_valid)
            
            clf = lgb.train(params, trn_data, 100000,
                            valid_sets=[trn_data, val_data],
                            verbose_eval=5000, early_stopping_rounds=5000)
            oof[val_idx] = clf.predict(X_data.iloc[val_idx], num_iteration=clf.best_iteration)
            getVal[val_idx] += clf.predict(X_data.iloc[val_idx], num_iteration=clf.best_iteration) / folds.n_splits
            
            feature_importance_df = pd.DataFrame()
            feature_importance_df['feature'] = features
            feature_importance_df['importance'] = clf.feature_importance()
            feature_importance_df['fold'] = fold_ + 1
            feature_importance = pd.concat([feature_importance, feature_importance_df], axis=0)
            predictions += clf.predict(X_test, num_iteration=clf.best_iteration) / folds.n_splits
        return feature_importance, predictions, oof, getVal


    def plot_importance(feature_importance):
        feature_importance["importance"] /= 5
        cols = feature_importance[["feature", "importance"]].groupby("feature").mean().sort_values(
            by="importance", ascending=False)[:50].index

        best_features = feature_importance.loc[feature_importance.feature.isin(cols)]
        logging.info('Top features')
        for f in best_features.sort_values(by="importance", ascending=False)['feature'].values:
            logging.info(f)

        plt.figure(figsize=(16, 12));
        sns.barplot(x="importance", y="feature", data=best_features.sort_values(by="importance", ascending=False));
        plt.title('LGB Features (avg over folds)')
        plt.show()


def plot_col_dist(df, figsize=(20, 20)):
    f = plt.figure(figsize=figsize)
    num = len(df.columns)
    div, mod = divmod(num, 3)
    if mod == 0:
        row_num = div
    else:
        row_num = div + 1
    for i, col in enumerate(df.columns):
        ax=f.add_subplot(row_num,3,i+1)
        sns.distplot(df[col].ffill(),kde=False)
        ax.set_title(col+" Distribution",color='Blue')
        plt.ylabel('Distribution')
    f.tight_layout()
    plt.show()

def headmap(df):
    corr = df.corr()
    f, ax = plt.subplots(figsize=(20, 15))
    cmap = sns.diverging_palette(200, 5, as_cmap=True)
    sns.heatmap(corr, cmap=cmap)
    plt.show()

def plot_roc(y_test, pred):
    fpr, tpr, threshold = roc_curve(y_test, pred)
    auc = roc_auc_score(y_test, pred)
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.plot(fpr, tpr, label='AUC='+str(auc))
    ax.plot(fpr, fpr, 'k--', label='Chance Curve')
    ax.set_xlabel('False Positive Rate', fontsize=12)
    ax.set_ylabel('True Positive Rate', fontsize=12)
    ax.grid(True)
    ax.legend(fontsize=12)
    plt.show()

def plot_tree(model, feature_names, class_names, proportion=True,leaves_parallel=True,filled=True):
    temp = tree.export_graphviz(model,feature_names=feature_names, class_names=class_names,
                    proportion=proportion, leaves_parallel=leaves_parallel, filled=filled)
    graph = graphviz.Source(temp)
    return graph

def missing_data(data):
    col_total = data.isnull().sum()
    percent = col_total / data.isnull().count() * 100
    missing_df = pd.concat([col_total, percent], axis=1,
                           keys=['Total', 'Percent'])
    types = []
    for col in data.columns:
        types.append(str(data[col].dtypes))
    missing_df['Types'] = types
    return np.transpose(missing_df)

def LBOH_trans(data, col_list, trans='OH'):
    if trans == 'LB':
        for col in col_list:
            lb = LabelEncoder()
            data[col] = lb.fit_transform(data[col])
        return data
    elif trans == 'OH':
        data = pd.get_dummies(data, columns=col_list)
        return data
    else:
        ValueError