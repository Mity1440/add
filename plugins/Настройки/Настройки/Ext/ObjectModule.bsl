﻿Перем КонтекстЯдра;
Перем КоллекцияИсключаемыхКлючей;

// { Plugin interface

Функция ОписаниеПлагина(КонтекстЯдра, ВозможныеТипыПлагинов) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Тип", ВозможныеТипыПлагинов.Утилита);
	Результат.Вставить("Идентификатор", "Настройки");
	Результат.Вставить("Представление", "Управление внешними настройками тестирования");

	Возврат Новый ФиксированнаяСтруктура(Результат);
КонецФункции

Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
	КонтекстЯдра = КонтекстЯдраПараметр;
КонецПроцедуры

// } Plugin interface

// { Settings interface

// Функция - Получить настройки
//
// Возвращаемое значение:
//   - Структура
//
// &НаКлиенте
Функция ПолучитьНастройки() Экспорт
	ИмяКлючаФайлаНастройки = "configpath";
	КонтекстЯдра = КонтекстЯдра();

	Если Настройки = Неопределено Тогда
		ПутьФайлаНастроек = КонтекстЯдра.ПутьФайлаНастроек();

		ФайлНастройки = Новый Файл(ПутьФайлаНастроек);
		СоздатьКоллекцияИсключаемыхКлючей();

		Настройки = ПрочитатьНастройкиИзФайлаJSon(ПутьФайлаНастроек);
		Настройки = ДобавитьВНастройкиДанныеИзВложенныхФайловНастроек(Настройки, ИмяКлючаФайлаНастройки, ФайлНастройки.Путь);
		Настройки = Новый ФиксированнаяСтруктура(Настройки);

		Если Настройки.Свойство("Отладка") Тогда
			ЕстьФлагОтладки = Настройки.Отладка;

			Если ЕстьСвойство(КонтекстЯдра, "ФлагОтладки") Тогда
				КонтекстЯдра.ФлагОтладки  = ЕстьФлагОтладки;
				КонтекстЯдра.Отладка(КонтекстЯдра.СтрШаблон_("НовоеЗначение КонтекстЯдра.ФлагОтладки %1", КонтекстЯдра.ФлагОтладки));
			КонецЕсли;
			Если ЕстьСвойство(КонтекстЯдра, "DebugLog") Тогда
				КонтекстЯдра.DebugLog  = ЕстьФлагОтладки;
				КонтекстЯдра.Отладка(КонтекстЯдра.СтрШаблон_("НовоеЗначение КонтекстЯдра.DebugLog %1", КонтекстЯдра.DebugLog));
			КонецЕсли;

			КонтекстЯдра.Отладка(КонтекстЯдра.СтрШаблон_("ЕстьСвойство(КонтекстЯдра, ФлагОтладки) %1", ЕстьСвойство(КонтекстЯдра, "ФлагОтладки")));
			КонтекстЯдра.Отладка(КонтекстЯдра.СтрШаблон_("КонтекстЯдра.ФлагОтладки %1", КонтекстЯдра.ФлагОтладки));

			Если ЕстьФлагОтладки Тогда
				КонтекстЯдра.Отладка("");
				КонтекстЯдра.Отладка("Файл настроек <" + ПутьФайлаНастроек + ">");
				КонтекстЯдра.Отладка("Переданные настройки:");
				ПоказатьСвойстваВРежимеОтладки(Настройки);
				КонтекстЯдра.Отладка("");
			КонецЕсли;
		КонецЕсли;

	КонецЕсли;
	Возврат Настройки;
КонецФункции

// Функция - Получить настройку
//
// Параметры:
//  КлючНастройки	 - 	 -
//
// Возвращаемое значение:
//   -
//
Функция ПолучитьНастройку(Знач КлючНастройки) Экспорт

	ПолучитьНастройки();

	Результат = Неопределено;
	Настройки.Свойство(КлючНастройки, Результат);
	Возврат Результат;

КонецФункции

// Позволяет одним вызовом получить значение из вложенных друг в друга структур
// по строке ключей, объединенных точкой.
//
// Параметры:
//  ПутьНастроек		 - Строка	 - Путь или ключ настроек
//  СтруктураНастроек	 - Произвольный, Неопределено - полученное значение
//		( необязательно )
//
// Возвращаемое значение:
//   Булево - Истина, если ключ/путь найден, иначе Ложь
//
// Пример:
// 		Структура = Новый Структура("Ключ1", Новый Структура("Ключ2", Новый Структура("Ключ3", 42)));
// 		Настройки.ДобавитьНастройки(Структура);
//		РезультатПроверки = Настройки.ЕстьНастройка("Ключ1.Ключ2.Ключ3");
// В результате получим Истина
//
//&НаКлиенте
Функция ЕстьНастройка(Знач ПутьНастроек, СтруктураНастроек = Неопределено) Экспорт

	Если СтруктураНастроек = Неопределено Тогда
		СтруктураНастроек = ПолучитьНастройки();
	КонецЕсли;

	Если ТипЗнч(СтруктураНастроек) = Тип("Структура") Или ТипЗнч(СтруктураНастроек) = Тип("ФиксированнаяСтруктура") Тогда

		ПозТочки = Найти(ПутьНастроек, ".");

		Если ПозТочки = 0 Тогда
			Возврат СтруктураНастроек.Свойство(ПутьНастроек);
		Иначе
			ИмяТекущегоСвойства = Лев(ПутьНастроек, ПозТочки - 1);
			ОстатокПути = Сред(ПутьНастроек, ПозТочки + 1);
			Если СтруктураНастроек.Свойство(ИмяТекущегоСвойства) Тогда
				Возврат ЕстьНастройка(ОстатокПути, СтруктураНастроек[ИмяТекущегоСвойства]);
			КонецЕсли;
		КонецЕсли;

	КонецЕсли;

	Возврат Ложь;

КонецФункции

// Процедура - Обновить
//
//&НаКлиенте
Процедура Обновить() Экспорт
	Настройки = Неопределено;
	ПолучитьНастройки();
КонецПроцедуры

// Добавить настройку к текущим настройкам
//
// Параметры:
//  Ключ	 - Строка	 - Наименование настройки
//  Значение - Произвольное	 - Значение настройки
//
Процедура ДобавитьНастройку(Знач Ключ, Знач Значение) Экспорт
	
	ПолучитьНастройки();
	
	НовыеНастройки = Новый Структура();
	Для каждого КлючЗначение Из Настройки Цикл
		НовыеНастройки.Вставить(КлючЗначение.Ключ, КлючЗначение.Значение);
	КонецЦикла;
	
	Если ТипЗнч(Ключ) = Тип("Строка") И НЕ ПустаяСтрока(Ключ) Тогда
		НовыеНастройки.Вставить(Ключ, Значение);
	КонецЕсли;
	
	Настройки = Новый ФиксированнаяСтруктура(НовыеНастройки);
КонецПроцедуры

// Добавить настройки к текущим настройкам
//
// Параметры:
//  ИсточникНастроек - Структура | Фиксированная структура	 - новые настройки, которые нужно добавить к текущим
//
Процедура ДобавитьНастройки(Знач ИсточникНастроек) Экспорт
	
	ПолучитьНастройки();
	
	НовыеНастройки = Новый Структура();
	Для каждого КлючЗначение Из Настройки Цикл
		НовыеНастройки.Вставить(КлючЗначение.Ключ, КлючЗначение.Значение);
	КонецЦикла;
	
	КонтекстЯдра().Отладка("Добавляю настройки:");
	ПоказатьСвойстваВРежимеОтладки(ИсточникНастроек);
	
	Если ТипЗнч(ИсточникНастроек) = Тип("Структура") ИЛИ ТипЗнч(ИсточникНастроек) = Тип("ФиксированнаяСтруктура") Тогда
		Для каждого КлючЗначение Из ИсточникНастроек Цикл
			НовыеНастройки.Вставить(КлючЗначение.Ключ, КлючЗначение.Значение);
		КонецЦикла;
	КонецЕсли;
	
	Настройки = Новый ФиксированнаяСтруктура(НовыеНастройки);
	
КонецПроцедуры

// Процедура - Показать свойства в режиме отладки
//
// Параметры:
//  ПараметрыПараметр	 - 	 -
//  Отступ				 - 	 -
//
Процедура ПоказатьСвойстваВРежимеОтладки(Знач ПараметрыПараметр, Знач Отступ = "") Экспорт
	КонтекстЯдра = КонтекстЯдра();
	ТипПараметра = ТипЗнч(ПараметрыПараметр);
	
	Если ТипПараметра = Тип("ФиксированныйМассив") Тогда
		Для Каждого Значение Из ПараметрыПараметр Цикл
			Если ТипЗнч(Значение) = Тип("ФиксированныйМассив") Или
				ТипЗнч(Значение) = Тип("Структура") Или
				ТипЗнч(Значение) = Тип("ФиксированнаяСтруктура") Тогда

					КонтекстЯдра.Отладка(Отступ + "количество = <" + Значение.Количество() + ">");
					ПоказатьСвойстваВРежимеОтладки(Значение, Отступ + "   ");
			Иначе
					КонтекстЯдра.Отладка(Отступ + "Значение = <" + Значение + ">");
			КонецЕсли;
		КонецЦикла;
	Иначе
		Если (ТипПараметра = Тип("Структура") ИЛИ ТипПараметра = Тип("ФиксированнаяСтруктура")) Тогда
			Для Каждого КлючЗначение Из ПараметрыПараметр Цикл
				Значение = КлючЗначение.Значение;
				Если ТипЗнч(Значение) = Тип("ФиксированныйМассив") Или
					ТипЗнч(Значение) = Тип("Структура") Или
					ТипЗнч(Значение) = Тип("ФиксированнаяСтруктура") Тогда

						КонтекстЯдра.Отладка(Отступ + "Ключ <" + КлючЗначение.Ключ + ">, количество = <" + Значение.Количество() + ">");
						ПоказатьСвойстваВРежимеОтладки(Значение, Отступ + "   ");
				Иначе
						КонтекстЯдра.Отладка(Отступ + "Ключ <" + КлючЗначение.Ключ + ">, Значение = <" + Значение + ">");
				КонецЕсли;
			КонецЦикла;
		Иначе
			КонтекстЯдра.Отладка(Отступ + "Значение = <" + ТипПараметра + ">");
		КонецЕсли;
	КонецЕсли;
	КонтекстЯдра.Отладка(Отступ + "");

КонецПроцедуры

// Получает значение настройки по указанному имени или пути, а также проверяет,
// имеется ли настройка по указанному пути.
//
// Параметры:
//  ПутьНастроек		 - Строка	 - Путь из ключей настройки разделенных точкой,
//    Например: "Ключ2.Ключ21"
//  ЗначениеНастройки	 - 	Произвольный - найденное значение настройки, если ключа
//    или пути из ключей нет в настройках, то возвращается Неопределено.
// 
// Возвращаемое значение:
//  Булево - признак того, что настройка найдена
//
Функция ЕстьЗначениеНастройки(Знач ПутьНастроек, ЗначениеНастройки) Экспорт
	Перем бЕстьНастройка, мЭлементыПути, стНастройки, элементКоллекции;
	
	ЗначениеНастройки = Неопределено;
	бЕстьНастройка = Ложь;
	
	Если ТипЗнч(ПутьНастроек) <> Тип("Строка") ИЛИ ПустаяСтрока(ПутьНастроек) Тогда
		Возврат бЕстьНастройка;
	КонецЕсли;
	
	мЭлементыПути = КонтекстЯдра().РазложитьСтрокуВМассивПодстрок(ПутьНастроек, ".", Ложь);
	Если мЭлементыПути.Количество() = 0 Тогда
		Возврат бЕстьНастройка;
	КонецЕсли;
	
	стНастройки = ПолучитьНастройки();
	
	Пока мЭлементыПути.Количество() > 0 Цикл
		
		элементКоллекции = Неопределено;
		Если НЕ стНастройки.Свойство(мЭлементыПути[0], элементКоллекции) Тогда
			Возврат бЕстьНастройка;
		КонецЕсли;
		
		Если мЭлементыПути.Количество() = 1 Тогда
			ЗначениеНастройки = элементКоллекции;
			бЕстьНастройка = Истина;
			Возврат бЕстьНастройка;
		КонецЕсли;
		
		Если НЕ(ТипЗнч(элементКоллекции) = Тип("Структура") ИЛИ ТипЗнч(элементКоллекции) = Тип("ФиксированнаяСтруктура")) Тогда
			Возврат бЕстьНастройка;
		КонецЕсли;
		
		стНастройки = элементКоллекции;
		мЭлементыПути.Удалить(0);
	КонецЦикла;
	
	Возврат бЕстьНастройка;
КонецФункции

// } Settings interface

Функция ДобавитьВНастройкиДанныеИзВложенныхФайловНастроек(Знач Настройки, Знач ИмяКлючаФайлаНастройки,
					Знач КаталогРодительскойНастройки)

	Результат = Новый Структура;
	Для каждого Настройка Из Настройки Цикл
		Значение = Настройка.Значение;
		Если ТипЗнч(Значение) = Тип("Структура") Тогда
			ПутьДопФайлаНастроек = Неопределено;
			Если Значение.Свойство(ИмяКлючаФайлаНастройки, ПутьДопФайлаНастроек) Тогда
				Значение = ПрочитатьНастройкиИзФайлаJSon(КаталогРодительскойНастройки + "/" + ПутьДопФайлаНастроек);
			КонецЕсли;
		КонецЕсли;

		Если ТипЗнч(Значение) = Тип("Строка") Тогда
			Значение = Заменить_workspaceRoot_на_РабочийКаталогПроекта(Значение);
		КонецЕсли;

		Результат.Вставить(Настройка.Ключ, Значение);
	КонецЦикла;
	Возврат Результат;

КонецФункции

Функция ПрочитатьНастройкиИзФайлаJSon(Знач ПутьФайлаНастроек)
	Результат = Новый Структура();
	ФайлНастроек = Новый Файл(ПутьФайлаНастроек);
	Если ФайлНастроек.Существует() Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.ОткрытьФайл(ПутьФайлаНастроек);

		Соответствие = ПрочитатьJSON(ЧтениеJSON, Истина);
		Результат = ПреобразоватьСоответствиеВСтруктуру(Соответствие, КоллекцияИсключаемыхКлючей);
	КонецЕсли;
	Возврат Результат;
КонецФункции

Функция ПреобразоватьСоответствиеВСтруктуру(Знач Соответствие, Знач КоллекцияИсключаемыхКлючей)
	Результат = Новый Структура;
	Для каждого КлючЗначение Из Соответствие Цикл
		Если КоллекцияИсключаемыхКлючей.Получить(КлючЗначение.Ключ) = Неопределено Тогда
			Значение = КлючЗначение.Значение;
			Если ТипЗнч(Значение) = Тип("Соответствие") Тогда
				Значение = ПреобразоватьСоответствиеВСтруктуру(Значение, КоллекцияИсключаемыхКлючей);
			КонецЕсли;

			Попытка

				Результат.Вставить(КлючЗначение.Ключ, Значение);

			Исключение
				Инфо = ИнформацияОбОшибке();
				ОписаниеОшибки = "Ошибка загрузки настроек. Неверный ключ
				|" + КлючЗначение.Ключ + "
				|" + ПодробноеПредставлениеОшибки(Инфо);

				КонтекстЯдра.ЗафиксироватьОшибкуВЖурналеРегистрации("Настройки", ОписаниеОшибки);

				КонтекстЯдра.ВывестиСообщение(ОписаниеОшибки, СтатусСообщения.ОченьВажное);

				ВызватьИсключение;

			КонецПопытки;
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

Процедура СоздатьКоллекцияИсключаемыхКлючей()
	КоллекцияИсключаемыхКлючей = Новый Соответствие;
	КоллекцияИсключаемыхКлючей.Вставить("$schema", "$schema");
КонецПроцедуры

Функция Заменить_workspaceRoot_на_РабочийКаталогПроекта(Знач ИсходнаяСтрока)
	Возврат СтрЗаменить(ИсходнаяСтрока, "$workspaceRoot", КонтекстЯдра.КаталогПроекта);
КонецФункции

// Универсальная функция для проверки наличия свойств у значения любого типа данных
//
// Параметры:
//   Объект - Любой - Коллекция любого типа, для которой необходимо проверить наличие свойства
//   ИмяСвойства - Строка - имя проверяемого свойства
//
//  Возвращаемое значение:
//   Булево - Истина, если свойство существует
//
Функция ЕстьСвойство(Знач Объект, Знач ИмяСвойства) Экспорт
    НачальноеЗНачение = Новый УникальныйИдентификатор();
    ЗначениеРеквизита = Новый Структура(ИмяСвойства, НачальноеЗНачение);
    ЗаполнитьЗначенияСвойств(ЗначениеРеквизита, Объект);
    Если ЗначениеРеквизита[ИмяСвойства] <> НачальноеЗНачение Тогда
        Возврат Истина;
    КонецЕсли;
    Возврат Ложь;
КонецФункции

Процедура _ДобавитьНастройку(Знач КоллекцияНастроек, Знач Ключ, Знач Значение)

	КонтекстЯдра.Отладка("ТипЗнч(КоллекцияНастроек) <" + ТипЗнч(КоллекцияНастроек) + ">");

	КоллекцияНастроек.Вставить(Ключ, Значение);

	КонтекстЯдра.Отладка("Добавил настройку <" + Ключ + ">, Значение = <" + Значение + ">");

КонецПроцедуры

Функция КонтекстЯдра()
	Если КонтекстЯдра = Неопределено Тогда
		Возврат ВнешниеОбработки.Создать("xddTestRunner");
	КонецЕсли;
	Возврат КонтекстЯдра;
КонецФункции
