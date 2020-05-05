# Sagu Raytracer
A tiny cross-platform object pascal raytracer

Baseado inicialmente no [Delphi-tinyraytracer](https://github.com/jersonSeling/Delphi-tinyraytracer) que por sua vez é baseado no [ssloy tinyraytracer](https://github.com/ssloy/tinyraytracer/wiki/Part-1:-understandable-raytracing).

Implementado em Object Pascal usando Lazarus/FPC e Delphi com o objetivo de ser utilizável tanto no Windows quanto Linux.
É uma aplicação de console/CLI que lê um arquivo JSON contendo a descrição de uma cena 3D e renderiza ela, gerando um arquivo de imagem gráfica, no formato [PPM (Portable PixMap)](https://en.wikipedia.org/wiki/Netpbm) no momento.

A ideia inicial é que essa aplicação sirva como um teste de benchmark entre os executáveis gerados em Lazarus/FPC e Delphi além das plataformas de destino, Windows ou Linux.

O projeto segue um principio de ser o mais simples possível, não dependendo de nenhuma biblioteca de terceiros. Usando apenas as ferramentas nativas disponíveis nos ambientes de desenvolvimento tal qual fossem recém instalados.

## Algumas considerações
- O uso de estruturas de dados que ocupam a stack em vez da heap nos calculos mais intesivos melhora consideravelmente a performance. Por isso os TVectors são records e não classes. Durante a renderização o algoritmo deve iterar por todos os objetos da cena para descobrir onde o raio bateu mais próximo a câmera. Usando TLists que armazenam objetos no heap essa iteração ficou mais lenta do que se usar arrays que ficam na stack também. 
- O uso de métodos inline gera ganho de desempenho como esperado.
- Os calculos dos TVectors foram armazenados como métodos desses records em vez de serem funções soltas. Isso serve para criar expressões de cálculos mais fluentes e fáceis de ler.
- Os executáveis gerados sem o uso de processamento paralelo pelo Lazarus/FPC parecem ser 30% mais rápidos que os gerados em Delphi nas análises que fiz até o momento, configurando o nível de otimização de ambos os compiladores para o máximo possível.
- Não comparei os desempenhos usando processamento paralelo nos dois compiladores. Mas, o melhor tempo de renderização do [Delphi-tinyraytracer](https://github.com/jersonSeling/Delphi-tinyraytracer) usando a PPL do Delphi foi praticamente igual ao melhor tempo do Sagu Raytracer compilado no Lazarus/FPC sem processamento paralelo. É claro que o tinyraytracer não é uma aplicação console, e não tem muita otimização no momento, fazendo a comparação um pouco injusta, mas não totalmente, pois creio que mesmo com elas, o resultado não seria muito melhor. Por exemplo, o uso de métodos inline no Lazarus/FPC mostrou um ganho de performace de 30%, enquanto que no Delphi o ganho foi bem menor que isso. (As tabelas com comparativos virão em breve)

## To Do
- Verificar o uso de operator overloading.
- Processamento paralelo no Lazarus/FPC.
- Mais formas geométricas.
- Carga de arquivos OBJ.
- Métodos de cálculos fluentes retornarem ponteiros para o objeto original alterado em vez de criarem novos objetos, fazendo um "reaproveitamento de variáveis" mais sofisticado e com isso ganhar desempenho ao não precisar alocar mais memória.
- Adicionar renderização baseado em [Path Tracing](https://en.wikipedia.org/wiki/Path_tracing). Ver tutoriais do [Raytracing in One Weekend](https://raytracing.github.io/) para isso.
- Arquitetura API para usar em testes de outros tipos de aplicação (Web APIs REST, etc).


Porquê Sagu?
Por que eu estava fazendo [sagu](https://pt.wikipedia.org/wiki/Sagu_(sobremesa)) na hora que tive a ideia deste projeto.
