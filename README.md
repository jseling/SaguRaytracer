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
- Tenho q ver ainda o uso de operators overrides.
