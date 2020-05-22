﻿
// { Plugin interface
&НаКлиенте
Функция ОписаниеПлагина(ВозможныеТипыПлагинов) Экспорт
	Возврат ОписаниеПлагинаНаСервере(ВозможныеТипыПлагинов);
КонецФункции

&НаСервере
Функция ОписаниеПлагинаНаСервере(ВозможныеТипыПлагинов)
	Возврат ЭтотОбъектНаСервере().ОписаниеПлагина(ВозможныеТипыПлагинов);
КонецФункции

&НаКлиенте
Процедура Инициализация(КонтекстЯдраПараметр) Экспорт

КонецПроцедуры

// } Plugin interface

&НаКлиенте
Функция СоздатьКонтейнер(ИмяКонтейнера, ИконкаУзла = Неопределено) Экспорт
	Контейнер = Новый Структура;
	Контейнер.Вставить("Ключ", Новый УникальныйИдентификатор);
	Контейнер.Вставить("Тип", ТипыУзловДереваТестов.Контейнер);
	Контейнер.Вставить("Имя", ИмяКонтейнера);
	Контейнер.Вставить("Путь", "");
	Контейнер.Вставить("Строки", Новый Массив);
	Контейнер.Вставить("ИконкаУзла", ?(ИконкаУзла = Неопределено, ИконкиУзловДереваТестов.Папка, ИконкаУзла));
	Контейнер.Вставить("СлучайныйПорядокВыполнения", Истина);
	Контейнер.Вставить("ПродолжитьВыполнениеПослеПаденияТеста", Истина);
	Контейнер.Вставить("Контекст", Неопределено);
	Контейнер.Вставить("ЭлементДеструктор", Неопределено);

	Возврат Контейнер;
КонецФункции

&НаКлиенте
Функция СоздатьЭлемент(Путь, ИмяМетода, Представление = "", ИконкаУзла = Неопределено) Экспорт
	Элемент = Новый Структура;
	Элемент.Вставить("Ключ", Новый УникальныйИдентификатор);
	Элемент.Вставить("Тип", ТипыУзловДереваТестов.Элемент);
	Элемент.Вставить("Путь", Путь);
	Элемент.Вставить("ИмяМетода", ИмяМетода);
	Элемент.Вставить("Представление", ?(ПустаяСтрока(Представление), ИмяМетода, Представление));
	Элемент.Вставить("ИконкаУзла", ?(ИконкаУзла = Неопределено, ИконкиУзловДереваТестов.Функция, ИконкаУзла));
	Элемент.Вставить("Параметры", Новый Массив);
	Элемент.Вставить("ПередЗапускомТеста", "ПередЗапускомТеста");
	Элемент.Вставить("ПослеЗапускаТеста", "ПослеЗапускаТеста");

	Возврат Элемент;
КонецФункции

// { Helpers
&НаСервере
Функция ЭтотОбъектНаСервере()
	Возврат РеквизитФормыВЗначение("Объект");
КонецФункции
// } Helpers