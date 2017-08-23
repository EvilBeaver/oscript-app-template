///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды version
//
///////////////////////////////////////////////////////////////////////////////

Перем Лог;

Процедура ЗарегистрироватьКоманду(Знач Команда, Знач Парсер) Экспорт
	
	Лог = МенеджерПриложения.ПолучитьЛог();
	
КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры (необязательно) - Соответствие - дополнительные параметры
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач Приложение) Экспорт
	
	Приложение.ВывестиВерсию();
	
	Возврат Приложение.РезультатыКоманд().Успех;
	
КонецФункции // ВыполнитьКоманду
