-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2019 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

newPackage{ id = "basic", name = "Basic", weight = 1,
	small = {font="/data/font/Vera.ttf", normal=12, small=10, big=14},
	default = {font="/data/font/Vera.ttf", normal=12, small=10, big=14},
	bold = {font="/data/font/VeraBd.ttf", normal=12, small=10, big=14},
	mono = {font="/data/font/VeraMono.ttf", normal=12, small=10, big=14},
	flyer = {font="/data/font/INSULA__.ttf", normal=14, small=12, big=16},
	bignews = {font="/data/font/VeraMono.ttf", normal=30},
	resources_normal = {font="/data/font/Vera.ttf", bold=true, normal=12},
	resources_small = {font="/data/font/Vera.ttf", bold=true, normal=10},
	classic = {font="/data/font/Vera.ttf", normal=12, small=10, big=14},
	classic_mono = {font="/data/font/VeraMono.ttf", normal=12, small=10, big=14},
	insular = {font="/data/font/INSULA__.ttf", normal=14, small=12, big=16},
	terminal = {font="/data/font/VeraMono.ttf", normal=12, small=10, big=14},
}

newPackage{ id = "web", name = "Web", weight = 10,
	small = {font="/data/font/DroidSans.ttf", normal=12, small=10, big=14},
	default = {font="/data/font/DroidSans.ttf", normal=16, small=12, big=18},
	bold = {font="/data/font/DroidSans.ttf", bold=true, normal=16, small=12, big=18},
	zone = {font="/data/font/DroidSans.ttf", bold=true, normal=16, small=12, big=18},
	mono = {font="/data/font/DroidSansMono.ttf", normal=16, small=12, big=18},
	mono_small = {font="/data/font/DroidSansMono.ttf", normal=14, small=10, big=16},
	flyer = {font="/data/font/INSULA__.ttf", normal=14, small=12, big=16},
	bignews = {font="/data/font/DroidSansMono.ttf", normal=30},
	resources_normal = {font="/data/font/DroidSans.ttf", bold=true, normal=12},
	resources_small = {font="/data/font/DroidSans.ttf", bold=true, normal=10},
	classic = {font="/data/font/USENET_.ttf", normal=16, small=14, big=18},
	classic_mono = {font="/data/font/SVBasicManual.ttf", normal=14, small=10, big=16},
	insular = {font="/data/font/INSULA__.ttf", normal=14, small=12, big=16},
	terminal = {font="/data/font/DroidSansMono.ttf", normal=12, small=10, big=14},
}

newPackage{ id = "fantasy", name = "Fantasy", weight = 100,
	small = {font="/data/font/Salsa-Regular.ttf", normal=12, small=10, big=14},
	default = {font="/data/font/Salsa-Regular.ttf", normal=16, small=12, big=18},
	bold = {font="/data/font/Salsa-Regular.ttf", normal=16, small=12, big=18},
	mono = {font="/data/font/Salsa-Mono.ttf", normal=16, small=12, big=18},
	mono_small = {font="/data/font/Salsa-Mono.ttf", normal=14, small=10, big=16},
	flyer = {font="/data/font/Salsa-Regular.ttf", normal=14, small=12, big=16},
	bignews = {font="/data/font/Salsa-Regular.ttf", normal=30},
	resources_normal = {font="/data/font/Salsa-Regular.ttf", normal=14},
	resources_small = {font="/data/font/Salsa-Regular.ttf", normal=12},
	classic = {font="/data/font/USENET_.ttf", normal=16, small=14, big=18},
	classic_mono = {font="/data/font/SVBasicManual.ttf", normal=14, small=10, big=16},
	insular = {font="/data/font/INSULA__.ttf", normal=14, small=12, big=16},
	terminal = {font="/data/font/DroidSansMono.ttf", normal=12, small=10, big=14},
}


newPackage{ id = "chinese", name = "Chinese", weight = 100,
	small = {font="/data/font/zh_hans/WenQuanYiMicroHei.ttf", normal=12, small=10, big=14},
	default = {font="/data/font/zh_hans/WenQuanYiMicroHei.ttf", normal=16, small=12, big=18},
	bold = {font="/data/font/zh_hans/WenQuanYiMicroHei.ttf", normal=16, small=12, big=18},
	mono = {font="/data/font/zh_hans/WenQuanYiMicroHeiMono.ttf", normal=16, small=12, big=18},
	mono_small = {font="/data/font/zh_hans/WenQuanYiMicroHeiMono.ttf", normal=14, small=10, big=16},
	flyer = {font="/data/font/zh_hans/WenQuanYiMicroHei.ttf", normal=14, small=12, big=16},
	bignews = {font="/data/font/zh_hans/WenQuanYiMicroHei.ttf", normal=30},
	resources_normal = {font="/data/font/zh_hans/WenQuanYiMicroHei.ttf", normal=16},
	resources_small = {font="/data/font/zh_hans/WenQuanYiMicroHei.ttf", normal=14},
	classic = {font="/data/font/zh_hans/WenQuanYiMicroHei.ttf", normal=16, small=14, big=18},
	classic_mono = {font="/data/font/zh_hans/WenQuanYiMicroHeiMono.ttf", normal=14, small=10, big=16},
	insular = {font="/data/font/zh_hans/MaShanZheng-Regular.ttf", normal=14, small=12, big=16},
	terminal = {font="/data/font/zh_hans/WenQuanYiMicroHeiMono.ttf", normal=12, small=10, big=14},
}

newPackage{ id = "japanese", name = "Japanese", weight = 100,
	small = {font="/data/font/ja_JP/HigashiOme/HigashiOme-Gothic-1.3i.ttf", normal=11, small=9, big=13},
	default = {font="/data/font/ja_JP/HigashiOme/HigashiOme-Gothic-1.3i.ttf", normal=15, small=13, big=17},
	bold = {font="/data/font/ja_JP/HigashiOme/HigashiOme-Gothic-1.3i.ttf", normal=15, small=13, big=17},
	mono = {font="/data/font/ja_JP/NatuMono/NatuMono-Regular-20140812.ttf", normal=14, small=12, big=16},
	mono_small = {font="/data/font/ja_JP/NatuMono/NatuMono-Regular-20140812.ttf", normal=14, small=10, big=16},
	flyer = {font="/data/font/ja_JP/HigashiOme/HigashiOme-Gothic-1.3i.ttf", normal=14, small=12, big=16},
	bignews = {font="/data/font/ja_JP/HigashiOme/HigashiOme-Gothic-1.3i.ttf", normal=30},
	resources_normal = {font="/data/font/ja_JP/HigashiOme/HigashiOme-Gothic-1.3i.ttf", normal=15},
	resources_small = {font="/data/font/ja_JP/HigashiOme/HigashiOme-Gothic-1.3i.ttf", normal=13},
	classic = {font="/data/font/ja_JP/HigashiOme/HigashiOme-Gothic-1.3i.ttf", normal=14, small=12, big=16},
	classic_mono = {font="/data/font/ja_JP/NatuMono/NatuMono-Regular-20140812.ttf", normal=14, small=10, big=16},
	insular = {font="/data/font/ja_JP/XANO-U32-2004-0509/XANO-mincho-U32.ttf", normal=14, small=12, big=16},
	terminal = {font="/data/font/ja_JP/NatuMono/NatuMono-Regular-20140812.ttf", normal=12, small=10, big=14},
}

newPackage{ id = "korean", name = "Korean", weight = 100,
	small = {font="/data/font/ko_KR/JejuGothic.ttf", normal=11, small=9, big=13},
	default = {font="/data/font/ko_KR/JejuGothic.ttf", normal=15, small=13, big=17},
	bold = {font="/data/font/ko_KR/JejuGothic.ttf", normal=15, small=13, big=17},
	mono = {font="/data/font/ko_KR/D2Coding.ttf", normal=16, small=12, big=16},
	mono_small = {font="/data/font/ko_KR/D2Coding.ttf", normal=14, small=10, big=16},
	flyer = {font="/data/font/ko_KR/JejuGothic.ttf", normal=14, small=12, big=16},
	bignews = {font="/data/font/ko_KR/JejuGothic.ttf", normal=30},
	resources_normal = {font="/data/font/ko_KR/JejuGothic.ttf", normal=15},
	resources_small = {font="/data/font/ko_KR/JejuGothic.ttf", normal=13},
	classic = {font="/data/font/ko_KR/D2Coding.ttf", normal=14, small=12, big=16},
	classic_mono = {font="/data/font/ko_KR/D2Coding.ttf", normal=14, small=10, big=16},
	insular = {font="/data/font/ko_KR/songgang-gasa-regular.ttf", normal=14, small=12, big=16},
	terminal = {font="/data/font/ko_KR/D2Coding.ttf", normal=12, small=10, big=14},
}