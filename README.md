# MarvelHeroes

![Test coverage](https://img.shields.io/badge/coverage-50,4%25-green.svg)

<img src="https://github.com/BrunoScheltzke/MarvelHeroes/blob/master/heroList.PNG" width="250">        <img src="https://github.com/BrunoScheltzke/MarvelHeroes/blob/master/heroDetail.PNG" width="250">

## Installation
#### Clone the project
`$ git clone https://github.com/BrunoScheltzke/MarvelHeroes.git`

#### Install dependencies
`$ pod install`

# Infinite Scrolling👨‍💻
The app includes infinte scrolling to fetch a list of heroes as requested by the user(by scrolling down). The infinite scrolling feature is also included on the list of comics on the hero detail screen.

<img src="https://github.com/BrunoScheltzke/MarvelHeroes/blob/master/HeroList.gif" width="250">        <img src="https://github.com/BrunoScheltzke/MarvelHeroes/blob/master/HeroDetail.gif" width="250">

# Code Coverage👨‍💻
With only Unit Tests, this project is currently covering 50,4% of the code. Using MVVM and Dependency Injection I was able to test almost all non-UI code.

### Resources
Using [Crypto Swift](https://github.com/krzyzanowskim/CryptoSwift) I was able to generate a hash necessary to authenticate each request as described in the [Marvel API guidelines](https://developer.marvel.com/documentation/authorization). This library is very powerful to manage data encryption and it was more used on another [personal project](https://github.com/BrunoScheltzke/FakeApp). I have also used [Alamofire](https://www.github.com/Alamofire/Alamofire) to avoid most of the boilerplate of general url requests and for image chaching.

### Author
[Bruno Scheltzke 🙋‍♂️](https://www.linkedin.com/in/brunoscheltzke/)
