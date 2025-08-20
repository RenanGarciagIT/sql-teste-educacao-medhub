import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
import matplotlib.pyplot as plt
import seaborn as sns

# 1. Ler CSV
df = pd.read_csv(r'c:\Users\Ghost\sql-teste-educacao-medhub\data\dashboard_kpis.csv')

# 2. Criar a variável alvo (inscrições do próximo mês)
df['inscricoes_next'] = df['inscricoes_mes'].shift(-1)

# 3. Selecionar features e remover última linha (que terá NaN na coluna alvo)
features = ['inscricoes_mes', 'conclusoes_mes', 'horas_assistidas', 'alunos_ativos_30d']
df_model = df.dropna()

X = df_model[features]
y = df_model['inscricoes_next']

# 4. Dividir em treino e teste (opcional, mas bom para avaliar)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 5. Treinar o modelo
model = LinearRegression()
model.fit(X_train, y_train)

# 6. Fazer previsões
y_pred = model.predict(X_test)

# 7. Avaliar precisão
r2 = r2_score(y_test, y_pred)
print(f"Precisão R²: {r2:.4f}")

# 8. Coeficientes da regressão
print("Intercepto:", model.intercept_)

# 9. Visualizar previsão vs real
plt.figure(figsize=(8,5))
sns.scatterplot(x=y_test, y=y_pred)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--')
plt.xlabel("Inscrições reais")
plt.ylabel("Inscrições previstas")
plt.title("Previsão de inscrições do próximo mês")
plt.show()
