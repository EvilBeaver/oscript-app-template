///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором методов работы с командами приложения
//
// В большинстве проектов изменять данный модуль не требуется
//
///////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать cmdline

///////////////////////////////////////////////////////////////////

Перем Лог;

Перем ПарсерКоманд;
Перем ИсполнителиКоманд;
Перем ОбъектНастроек;
	
///////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЙ ОТКРЫТЫЙ ПРОГРАММНЫЙ ИНТЕРФЕЙС

//Инициализирует и настраивает приложение
// 
// Параметры:
//	Настройка - Модуль - Модуль, в котором определены настройки приложения
//
// Возвращаемое значение:
//   Модуль   - Модуль менеджера приложения
//
Функция Инициализировать(Знач Настройки) Экспорт
	
	// Служебные переменные
	ПарсерКоманд = Новый ПарсерАргументовКоманднойСтроки();
	ИсполнителиКоманд = Новый Соответствие;	
	ОбъектНастроек = Настройки;

	// Логирование
	Лог = Логирование.ПолучитьЛог(ОбъектНастроек.ИмяЛогаСистемы());
	Лог.УстановитьУровень(УровниЛога.Информация);
	Лог.УстановитьРаскладку(ОбъектНастроек);

	// Инициализация команд
	ОбъектНастроек.НастроитьКомандыПриложения(ЭтотОбъект);

	Возврат ЭтотОбъект;

КонецФункции

// Добавляет команду в приложение
//
// Параметры:
//	ИмяКоманды - Строка - Имя команды
//	КлассРеализации - Строка - Имя файла класса, в котором реализована команда
//	Описаниекоманды - Строка - краткое описание назначения команды
//
Процедура ДобавитьКоманду(Знач ИмяКоманды, Знач КлассРеализации, Знач ОписаниеКоманды) Экспорт

	РеализацияКоманды = Новый(КлассРеализации);
	
	Команда = ПарсерКоманд.ОписаниеКоманды(ИмяКоманды, ОписаниеКоманды);
	ПарсерКоманд.ДобавитьКоманду(Команда);
	
	РеализацияКоманды.НастроитьКоманду(Команда, ПарсерКоманд);

	ИсполнителиКоманд.Вставить(ИмяКоманды, РеализацияКоманды);

КонецПроцедуры

// Аварийно завершает работу приложения с ошибкой
// 
// Параметры:
//	Сообщение - Строка - Сообщение, которое будет выведено пользователю перед завершением
//  КодВозврата (не обязательный) - Число - Код возврата с которым будет закрыто приложение
//   Значение по умолчанию: "ОшибкаВремениВыполнения" -- 1
//
Процедура ЗавершитьРаботуПриложенияСОшибкой(Знач Сообщение, Знач КодВозврата = Неопределено) Экспорт

	Если КодВозврата = Неопределено Тогда
		КодВозврата = 1;
	КонецЕсли;

	Лог.КритичнаяОшибка(Сообщение);
	
	ЗавершитьРаботу(КодВозврата);

КонецПроцедуры

// Завершает работу приложения
// 
// Параметры:
//  КодВозврата (не обязательный) - Число - Код возврата с которым будет закрыто приложение
//   Значение по умолчанию: "Успех" -- 0
//
Процедура ЗавершитьРаботуПриложения(Знач КодВозврата = Неопределено) Экспорт
	
	Если КодВозврата = Неопределено Тогда
		КодВозврата = 0;
	КонецЕсли;

	ЗавершитьРаботу(КодВозврата);

КонецПроцедуры

// Осуществляет запуск приложения на выполнение
//
// Возвращаемое значение:
//	Число - Код возврата выполнения команды приложения
//
Функция ЗапуститьВыполнение() Экспорт
	
	Попытка
		ПараметрыЗапуска = ПарсерКоманд.Разобрать(АргументыКоманднойСтроки);
	Исключение
		Лог.Отладка(ОписаниеОшибки());

		Лог.Ошибка("Не удалось определить требуемое действие.");
		ВывестиСправкуПоКомандам();

		Возврат 5;
	Конецпопытки;
	
	Команда = "";
	ЗначенияПараметров = Неопределено;
	
	Если ТипЗнч(ПараметрыЗапуска) = Тип("Структура") Тогда
		
		// это команда
		Команда				= ПараметрыЗапуска.Команда;
		ЗначенияПараметров	= ПараметрыЗапуска.ЗначенияПараметров;
		Лог.Отладка("Выполняю команду продукта %1", Команда);
		
	ИначеЕсли ЗначениеЗаполнено(ОбъектНастроек.ИмяКомандыПоУмолчанию()) Тогда
		
		// это команда по-умолчанию
		Команда				= ОбъектНастроек.ИмяКомандыПоУмолчанию();
		ЗначенияПараметров	= ПараметрыЗапуска;
		Лог.Отладка("Выполняю команду продукта по умолчанию %1", Команда);
		
	Иначе
		
		ВывестиСправкуПоКомандам();
		
		Возврат 5;
		
	КонецЕсли;
	
	Если Команда <> ОбъектНастроек.ИмяКомандыВерсия() Тогда

		ВывестиВерсию();

	КонецЕсли;
	
	Возврат ВыполнитьКоманду(Команда, ЗначенияПараметров);
	
КонецФункции // ЗапуститьВыполнение()

// Осуществляет запуск на выполнение указанной команды приложения
//
// Параметры:
//	ИмяКоманды - Строка - Имя команды, которую необходимо запустить
//	ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//
Функция ВыполнитьКоманду(Знач ИмяКоманды, Знач ПараметрыКоманды) Экспорт
	
	Команда = ПолучитьКоманду(ИмяКоманды);
	КодВозврата = Команда.ВыполнитьКоманду(ПараметрыКоманды, ЭтотОбъект);

	Если КодВозврата = Неопределено Тогда
		КодВозврата = 0;
	КонецЕсли;

	Возврат КодВозврата;

КонецФункции // ВыполнитьКоманду

///////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС

// Возвращает лог приложения
Функция ПолучитьЛог() Экспорт

	Возврат Лог;

КонецФункции // ПолучитьЛог

// Возвращает версию продукта
Функция ВерсияПродукта() Экспорт
	
	Возврат ОбъектНастроек.ВерсияПродукта();
	
КонецФункции // ВерсияПродукта

// Возвращает имя продукта
Функция ИмяПродукта() Экспорт
	
	Возврат ОбъектНастроек.ИмяПродукта();
	
КонецФункции // ИмяПродукта

// Выводит справку по всем командам приложения
Процедура ВывестиСправкуПоКомандам() Экспорт

	ПарсерКоманд.ВывестиСправкуПоКомандам();
	
КонецПроцедуры // ВывестиСправкуПоКомандам

// Выводит справку по указанной команде приложения.
Процедура ВывестиСправкуПоКоманде(Знач ИмяКоманды) Экспорт

	ПарсерКоманд.ВывестиСправкуПоКоманде(ИмяКоманды);

КонецПроцедуры // ВывестиСправкуПоКоманде

///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// Получает объект класса с реализацией указанной команды
Функция ПолучитьКоманду(Знач ИмяКоманды)
	
	КлассРеализации = ИсполнителиКоманд[ИмяКоманды];
	Если КлассРеализации = Неопределено Тогда

		ВызватьИсключение СтрШаблон("Неверная операция. Команда '%1' не предусмотрена.", ИмяКоманды);

	КонецЕсли;
	
	Возврат КлассРеализации;
	
КонецФункции // ПолучитьКоманду

// Осуществляет вывод полной версии продукта
Процедура ВывестиВерсию()
	
	Сообщить(СтрШаблон("%1 v%2", ИмяПродукта(), ВерсияПродукта()));
	
КонецПроцедуры // ВывестиВерсию
