# Maintainer:  lolilolicon <lolilolicon#gmail#com>

pkgname=pacmaria2
pkgver=1.2
pkgrel=1
pkgdesc="pacman package metalink generator and downloader."
arch=(any)
url="http://lolilolicon.github.com/pacmaria2"
license=('MIT')
depends=(bash aria2)
optdepends=(reflector)
source=(https://github.com/downloads/lolilolicon/$pkgname/$pkgname-$pkgver.tar.gz)
md5sums=('f84e6998e50bb185d307af19a65bfe67')

package() {
  cd "$srcdir/$pkgname-$pkgver"
  install -Dm 755 ${pkgname}.sh "$pkgdir"/usr/bin/${pkgname}
}
