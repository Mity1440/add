﻿&НаКлиенте
Перем КонтекстЯдра;

// { Plugin interface
&НаКлиенте
Функция ОписаниеПлагина(КонтекстЯдра, ВозможныеТипыПлагинов) Экспорт
	Возврат ОписаниеПлагинаНаСервере(ВозможныеТипыПлагинов);
КонецФункции

&НаСервере
Функция ОписаниеПлагинаНаСервере(ВозможныеТипыПлагинов)
	КонтекстЯдраНаСервере = ВнешниеОбработки.Создать("xddTestRunner");
	Возврат ЭтотОбъектНаСервере().ОписаниеПлагина(КонтекстЯдраНаСервере, ВозможныеТипыПлагинов);
КонецФункции

&НаКлиенте
Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
	КонтекстЯдра = КонтекстЯдраПараметр;
КонецПроцедуры

// } Plugin interface

// { API

// Загружает настройки из указанного поставщика как глобальные переменные контекста, которые могу быть использованы в фичах
//
// Параметры:
//  ИмяПоставщикаСервиса - Строка - см функцию ПоддерживаемыеПоставщики()
//  АдресНастроек - Строка - Путь к настройкам, формат пути определяется поставщиком и описан в функции ЗапроситьНастройки()
//
&НаКлиенте
Процедура ЗагрузитьНастройки(ИмяПоставщикаСервиса, АдресНастроек = "") Экспорт

	ПоставщикСервиса = НовыйПоставщикСервиса(ИмяПоставщикаСервиса);

	НастройкиПользователя = Неопределено;
	Если ПоставщикСервиса.Имя = ИмяПоставщикаCONSUL() Тогда
		НастройкиПользователя = ЗапроситьНастройкиCONSUL(АдресНастроек);
	ИначеЕсли ПоставщикСервиса.Имя = ИмяПоставщикаFILE() Тогда
		НастройкиПользователя = ЗапроситьНастройкиFILE(АдресНастроек);
	КонецЕсли;

	Для каждого СтрокаНастроек Из НастройкиПользователя Цикл
		Попытка
			КонтекстЯдра.ОбъектКонтекстСохраняемый.Вставить(СтрокаНастроек.Ключ, СтрокаНастроек.Значение);
		Исключение
			//значит надо сохранить значение не в структуру а в соответствие
			КонтекстЯдра.СохранитьЗначениеВКонтекстСохраняемый(СтрокаНастроек.Ключ, СтрокаНастроек.Значение);
		КонецПопытки;
	КонецЦикла;

	ВывестиЗагруженныеНастройкиВЖР(НастройкиПользователя);

КонецПроцедуры

// Имя поставщика CONSUL
//
// Возвращаемое значение:
//   -
//
&НаКлиенте
Функция ИмяПоставщикаCONSUL() Экспорт
	Возврат "CONSUL";
КонецФункции

// Имя поставщика FILE
//
// Возвращаемое значение:
//   -
//
&НаКлиенте
Функция ИмяПоставщикаFILE() Экспорт
	Возврат "FILE";
КонецФункции

// } API

// { Helpers

// Запрашивает настройки из key-value хранилища Consul
//
// Параметры:
//  АдресНастроек - Строка - полный URL к JSON-у настроек в консуле. Например: http://127.0.0.1:8500/v1/kv/adapter/users/ivanov
//
// Возвращаемое значение:
//  Структура - структура, где ключи значения соответствуют ключам и значениям настроек в консуле, полученных рекурсивно
//
&НаКлиенте
Функция ЗапроситьНастройкиCONSUL(АдресНастроек = "")

	СтруктураНастроек = Новый Структура();

	ПолныйАдрес = ?(ЗначениеЗаполнено(АдресНастроек), АдресНастроек, "http://127.0.0.1:8500/v1/kv/");

	АдресБезHTTP = СтрЗаменить(ПолныйАдрес, "http://", "");
	ИндексПараметров = Найти(АдресБезHTTP, "?");
	Если ИндексПараметров > 0 Тогда
		АдресБезHTTPБезПараметров = Лев(АдресБезHTTP, ИндексПараметров - 1);
	Иначе
		АдресБезHTTPБезПараметров = АдресБезHTTP;
	КонецЕсли;

	ЧастиАдреса = КонтекстЯдра.РазложитьСтрокуВМассивПодстрокКлиент(АдресБезHTTPБезПараметров, "/", Истина);
	СерверСПортом = ЧастиАдреса[0];
	Сервер = Лев(СерверСПортом, Найти(СерверСПортом, ":") - 1);
	Порт = Прав(СерверСПортом, СтрДлина(СерверСПортом) - Найти(СерверСПортом, ":"));
	АдресБезСервера = СтрЗаменить(АдресБезHTTPБезПараметров, СерверСПортом, "");
	ПоследнийПараметр = ЧастиАдреса[ЧастиАдреса.Количество() - 1];

	Соединение = Новый HTTPСоединение(Сервер, Число(Порт));

	Запрос = Новый HTTPЗапрос(АдресБезСервера + "?recurse=true&raw=true");
	Ответ = Соединение.Получить(Запрос);

	УспешныйHTTPОтвет = 200;
	Если Ответ.КодСостояния <> УспешныйHTTPОтвет Тогда
		ТекстОшибки = "Ошибка! Запрос по адресу " + АдресНастроек + " вернул статус " + Строка(Ответ.КодСостояния);
		ВывестиОшибкуВЖР(ТекстОшибки);
		КонтекстЯдра.СделатьСообщение(ТекстОшибки, "Внимание");
		Возврат СтруктураНастроек;
	КонецЕсли;

	ТелоОтвета = Ответ.ПолучитьТелоКакСтроку();

	ЧтениеJSON = Вычислить("Новый ЧтениеJSON()");
	ЧтениеJSON.УстановитьСтроку(ТелоОтвета);
	ОтветJSON = Вычислить("ПрочитатьJSON(ЧтениеJSON, Истина)");
	ЧтениеJSON.Закрыть();

	Для каждого СтрокаКлюча Из ОтветJSON Цикл
		КлючПараметра = СтрокаКлюча.Получить("Key");
		ЗначениеПараметра = СтрокаКлюча.Получить("Value");
		Если ЗначениеПараметра = Неопределено Тогда
			// Это каталог, его пропускаем
			Продолжить;
		КонецЕсли;

		ПутьККлючуКонсула = СтрЗаменить(
			КлючПараметра, Лев(КлючПараметра, СтрДлина(ПоследнийПараметр) + Найти(КлючПараметра, ПоследнийПараметр)), "");

		СтруктураНастроек.Вставить(
			ВРег(СтрЗаменить(ПутьККлючуКонсула, "/", "_")),
			ПолучитьСтрокуИзДвоичныхДанных(Base64Значение(ЗначениеПараметра))
		);

	КонецЦикла;

	Возврат СтруктураНастроек;

КонецФункции

// Запрашивает настройки из внешнего файла. Если не указан файл, то загружаются настройки из файла
// с именем user_settings.json. Формат файла должен быть следующего вида:
// {
//  "userSettings": [
//    {
//      "user": "USERNAME_1",
//      "settings": {
//        "ИМЯ_ПЕРЕМЕННОЙ_1": "ЗНАЧЕНИЕ_ПЕРЕМЕННОЙ_1",
//        "ИМЯ_ПЕРЕМЕННОЙ_2": "ЗНАЧЕНИЕ_ПЕРЕМЕННОЙ_2",
//      }
//    },
//    {
//      "user": "USERNAME_2",
//      "settings": {
//        "ИМЯ_ПЕРЕМЕННОЙ_1": "ЗНАЧЕНИЕ_ПЕРЕМЕННОЙ_1",
//        "ИМЯ_ПЕРЕМЕННОЙ_2": "ЗНАЧЕНИЕ_ПЕРЕМЕННОЙ_2",
//      }
//    }
//  ]
// }
//
// Параметры:
//  АдресНастроек - Строка - полное путь к файлу с именем, где находится файл с настройками. Если не указан то поиск настроек выполняется в корневом каталоге проекта
//
&НаКлиенте
Функция ЗапроситьНастройкиFILE(АдресНастроек = "")

	СтруктураНастроек = Новый Структура;

	Если Не ЗначениеЗаполнено(АдресНастроек) Тогда

		ИмяФайлаНастроек = "user_settings.json";

		ПутьКФайлу = КонтекстЯдра.ПреобразоватьПутьСТочкамиКНормальномуПути("$workspaceRoot\" + ИмяФайлаНастроек);

		ПутьКФайлу = ?(КонтекстЯдра.ФайлСуществуетКомандаСистемы(ПутьКФайлу), ПутьКФайлу,
			КонтекстЯдра.ПреобразоватьПутьСТочкамиКНормальномуПути("$instrumentsRoot\" + ИмяФайлаНастроек));

		ПутьКФайлу = ?(КонтекстЯдра.ФайлСуществуетКомандаСистемы(ПутьКФайлу), ПутьКФайлу,
			КаталогРепозитория() + "\" + ИмяФайлаНастроек);
	Иначе
		ПутьКФайлу = АдресНастроек;
	КонецЕсли;

	Если Не КонтекстЯдра.ФайлСуществуетКомандаСистемы(ПутьКФайлу) Тогда
		Возврат СтруктураНастроек;
	КонецЕсли;

	ЧтениеПеременных = Вычислить("Новый ЧтениеJSON()");
	ЧтениеПеременных.ОткрытьФайл(ПутьКФайлу);
	ГлобальныеПеременные = Вычислить("ПрочитатьJSON(ЧтениеПеременных, Истина)");
	ЧтениеПеременных.Закрыть();

	МассивНастроек = ГлобальныеПеременные["userSettings"];

	ТекЮзер = ТекущийПользовательОС();

	НастройкиЮзераНайдены = Ложь;
	Для каждого СтрокаПользователя Из МассивНастроек Цикл
		Если ВРег(СтрокаПользователя["user"]) = ВРег(ТекЮзер) Тогда
			НастройкиЮзераНайдены = Истина;
			СтрокаНастроек = СтрокаПользователя["settings"];
			Для каждого ПеремЮзера Из СтрокаНастроек Цикл
				СтруктураНастроек.Вставить(ПеремЮзера.Ключ, ПеремЮзера.Значение);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;

	Если Не НастройкиЮзераНайдены Тогда
		ТекстСообщения = КонтекстЯдра.ПолучитьТекстСообщенияПользователю(
			НСтр("ru = 'Предупреждение. Не найдены настройки пользователя %1 в файле %2'"));
		ТекстСообщения = СтрЗаменить(ТекстСообщения,"%1", ТекЮзер);
		ТекстСообщения = СтрЗаменить(ТекстСообщения,"%2", ПутьКФайлу);
		КонтекстЯдра.СделатьСообщение(ТекстСообщения);
	КонецЕсли;

	Возврат СтруктураНастроек;

КонецФункции

&НаКлиенте
Функция НовыйПоставщикСервиса(ИмяПоставщика)

	Если ПоддерживаемыеПоставщики().Найти(ИмяПоставщика) = Неопределено Тогда
		ВызватьИсключение "Поставщик сервиса """ + ИмяПоставщика + """ не поддерживается";
	КонецЕсли;

	НовыйПоставщик = Новый Структура();
	НовыйПоставщик.Вставить("Имя", ИмяПоставщика);

	Возврат НовыйПоставщик;

КонецФункции

&НаКлиенте
Функция ПоддерживаемыеПоставщики()

	Поставщики = Новый Массив;
	Поставщики.Добавить(ИмяПоставщикаCONSUL());
	Поставщики.Добавить(ИмяПоставщикаFILE());

	Возврат Поставщики;

КонецФункции

&НаСервере
Функция ЭтотОбъектНаСервере()
	Возврат РеквизитФормыВЗначение("Объект");
КонецФункции

&НаКлиенте
Функция ТекущийПользовательОС()

	СисИнфо = Новый СистемнаяИнформация;

	Если СисИнфо.ТипПлатформы = ТипПлатформы.Windows_x86
		Или СисИнфо.ТипПлатформы = ТипПлатформы.Windows_x86_64 Тогда

		ПользовательОС = "";
		Попытка
			NetWork = Новый COMObject("wscript.network");
			ПользовательОС = NetWork.Username;
		Исключение
			Shell = Новый COMОбъект("WScript.Shell");
			ПользовательОС = Shell.ExpandEnvironmentStrings("%USERNAME%");
		КонецПопытки;

	Иначе
		Сообщить(НСтр("ru = 'Функция ТекущийПользовательОС() реализована только для Windows';
			|en = 'Function for getting current username is implemented only for windows'"));
	КонецЕсли;

	Возврат ПользовательОС;

КонецФункции

&НаСервереБезКонтекста
Процедура ВывестиОшибкуВЖР(ТекстОшибки)
	ЗаписьЖурналаРегистрации("VanessaADD.ЗагрузкаГлобальныхПеременных",
		УровеньЖурналаРегистрации.Ошибка,,, ТекстОшибки);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ВывестиЗагруженныеНастройкиВЖР(знач НастройкиПользователя)

	НастройкиСтрокой = "";

	Для каждого СтрокаНастройки Из НастройкиПользователя Цикл
		НастройкиСтрокой = НастройкиСтрокой + Символы.ПС + СтрокаНастройки.Ключ + " " + СтрокаНастройки.Значение;
	КонецЦикла;

	ЗаписьЖурналаРегистрации("VanessaADD.ЗагрузкаГлобальныхПеременных",
		УровеньЖурналаРегистрации.Информация, , ,
		НСтр("ru = 'Загружены глобальные переменные'") + НастройкиСтрокой);

КонецПроцедуры

&НаКлиенте
Функция КаталогРепозитория() Экспорт

	Если КонтекстЯдра.ЭтоLinux Тогда
		Возврат ""; // TODO исправить получение каталога репозитория для Linux
	КонецЕсли;

	СтрокаКоманды = "CD /D """ + КонтекстЯдра.ИспользуемоеИмяФайла + """
		|git rev-parse --show-superproject-working-tree"; // если add используется как сабмодуль

	КонсольныйВывод = "";

	УправлениеПриложениями = КонтекстЯдра.Плагин("УправлениеПриложениями");
	УправлениеПриложениями.ВыполнитьКомандуОСБезПоказаЧерногоОкнаСВыводом(СтрокаКоманды,,, КонсольныйВывод);

	КорневойПутьПроекта = СокрЛП(СтрПолучитьСтроку(КонсольныйВывод, СтрЧислоСтрок(КонсольныйВывод)));

	Если Не КонтекстЯдра.ФайлСуществуетКомандаСистемы(КорневойПутьПроекта) Тогда
		СтрокаКоманды = "CD /D """ + КонтекстЯдра.ИспользуемоеИмяФайла + """
			|git rev-parse --show-toplevel"; // если add используется просто является вложенным каталогом

		УправлениеПриложениями.ВыполнитьКомандуОСБезПоказаЧерногоОкнаСВыводом(СтрокаКоманды,,, КонсольныйВывод);
		КорневойПутьПроекта = СокрЛП(СтрПолучитьСтроку(КонсольныйВывод, СтрЧислоСтрок(КонсольныйВывод)));
	КонецЕсли;

	Возврат КорневойПутьПроекта;

КонецФункции

// } Helpers

#Область ОбработчикиРеквизитовКомандФормы

&НаКлиенте
Процедура ЗагрузитьНастройкиКоманда(Команда)
	ЗагрузитьНастройки(ПоставщикПользовательскихНастроек, АдресПользовательскихНастроек);
КонецПроцедуры

#КонецОбласти