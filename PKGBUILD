# Maintainer:  lolilolicon <lolilolicon#gmail#com>

pkgname=pacmaria2
pkgver=1.0
pkgrel=1
pkgdesc="pacman package metalink generator and downloader."
arch=(any)
url="http://lolilolicon.github.com/pacmaria2"
license=('MIT')
depends=(bash aria2 reflector)
source=(https://github.com/downloads/lolilolicon/$pkgname/$pkgname-$pkgver.tar.gz)
md5sums=('d51406c02f1813dd04aa98bb1cc5f334')

build() {
  cd "$srcdir/$pkgname-$pkgver"
}
package() {
  cd "$srcdir/$pkgname-$pkgver"
  install -Dm 755 ${pkgname}.sh "$pkgdir"/usr/bin/${pkgname}
}
