#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.АктивныеПосещения.Записывать = Истина;
	Движения.Продажи.Записывать = Истина;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ПродажаБилетаПозицииПродажи.Номенклатура.ВидАттракциона КАК ВидАттракциона,
		|	ПродажаБилетаПозицииПродажи.Сумма,
		|	ПродажаБилетаПозицииПродажи.Номенклатура,
		|	ПродажаБилетаПозицииПродажи.Номенклатура.КоличествоПосещений * ПродажаБилетаПозицииПродажи.Количество КАК
		|		КоличествоПосещений
		|ИЗ
		|	Документ.ПродажаБилета.ПозицииПродажи КАК ПродажаБилетаПозицииПродажи
		|ГДЕ
		|	ПродажаБилетаПозицииПродажи.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();

	Выборка = РезультатЗапроса.Выбрать();

	Пока Выборка.Следующий() Цикл
		Движение = Движения.АктивныеПосещения.Добавить();
		Движение.Период = Дата;
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Основание = Ссылка;
		Движение.ВидАттракциона = Выборка.ВидАттракциона;
		Движение.КоличествоПосещений = Выборка.КоличествоПосещений;

		Движение = Движения.Продажи.Добавить();
		Движение.Период = Дата;
		Движение.Клиент = Клиент;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.ВидАттракциона = Выборка.ВидАттракциона;
		Движение.Сумма = Выборка.Сумма;
	КонецЦикла;

	ЗачислитьСписатьБонусныеБаллы(Отказ);

КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)

	МаксимальнаяДоля = Константы.МаксимальнаяДоляОплатыБаллами.Получить();

	СуммаПродажи = ПозицииПродажи.Итог("Сумма");
	Если БаллыКСписанию <> 0 Тогда

		Если БаллыКСписанию > СуммаПродажи Тогда
			Отказ = Истина;
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Баллы не должны превышать сумму продажи билета";
			Сообщение.УстановитьДанные(ЭтотОбъект);
			Сообщение.Поле = "БаллыКСписанию";
			Сообщение.Сообщить();
		КонецЕсли;

		Если удалитьЦена <> 0 Тогда
			Доля = БаллыКСписанию / СуммаПродажи * 100;
			Если Доля > МаксимальнаяДоля Тогда
				Отказ = Истина;
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = СтрШаблон("Доля баллов больше допустимой (%1%%)", МаксимальнаяДоля);
				Сообщение.УстановитьДанные(ЭтотОбъект);
				Сообщение.Поле = "БаллыКСписанию";
				Сообщение.Сообщить();
			КонецЕсли;
		КонецЕсли;
	
		Если Не ЗначениеЗаполнено(Клиент) Тогда
			Отказ = Истина;
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Списание баллов возможно только при указании клиента";
			Сообщение.УстановитьДанные(ЭтотОбъект);
			Сообщение.Поле = "БаллыКСписанию";
			Сообщение.Сообщить();
		КонецЕсли;
			
	КонецЕсли;

КонецПроцедуры
#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗачислитьСписатьБонусныеБаллы(Отказ)

	Движения.БонусныеБаллыКлиентов.Записывать = Истина;

	Если Не ЗначениеЗаполнено(Клиент) Тогда
		Возврат;
	КонецЕсли;

	СуммаПокупокКлиента = СуммаПокупокКлиента();

	ДоляНакапливаемыхБаллов = ДоляНакапливаемыхБаллов(СуммаПокупокКлиента);

	БаллыКНакоплению = СуммаДокумента * ДоляНакапливаемыхБаллов / 100;

	Если БаллыКНакоплению <> 0 Тогда
		Движение = Движения.БонусныеБаллыКлиентов.Добавить();
		Движение.ВидДвижения =ВидДвиженияНакопления.Приход;
		Движение.Клиент = Клиент;
		Движение.Сумма = БаллыКНакоплению;
		Движение.Период = Дата;
	КонецЕсли;

	Если БаллыКСписанию <> 0 Тогда
		Движение = Движения.БонусныеБаллыКлиентов.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Клиент = Клиент;
		Движение.Сумма = БаллыКСписанию;
		Движение.Период = Дата;
	КонецЕсли;
	
	Движения.Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	БонусныеБаллыКлиентовОстатки.СуммаОстаток
		|ИЗ
		|	РегистрНакопления.БонусныеБаллыКлиентов.Остатки(&Период, Клиент = &Клиент) КАК БонусныеБаллыКлиентовОстатки
		|ГДЕ
		|	БонусныеБаллыКлиентовОстатки.СуммаОстаток < 0";
	
	Запрос.УстановитьПараметр("Период", Новый Граница(МоментВремени(),ВидГраницы.Включая));
	Запрос.УстановитьПараметр("Клиент", Клиент);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();

	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон("Не хватает баллов на балансе - %1", ВыборкаДетальныеЗаписи.СуммаОстаток
			+ БаллыКСписанию);
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Поле = "БаллыКСписанию";
		Сообщение.Сообщить();
	КонецЦикла;

КонецПроцедуры

Функция СуммаПокупокКлиента()

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПродажиОбороты.СуммаОборот
	|ИЗ
	|	РегистрНакопления.Продажи.Обороты(, &КонецПериода,, Клиент = &Клиент) КАК ПродажиОбороты";

	Запрос.УстановитьПараметр("КонецПериода", Новый Граница(МоментВремени(), ВидГраницы.Исключая));
	Запрос.УстановитьПараметр("Клиент", Клиент);

	РезультатЗапроса = Запрос.Выполнить();

	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();

	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.СуммаОборот;// Вставить обработку выборки ВыборкаДетальныеЗаписи
	КонецЦикла;

	Возврат 0;

КонецФункции

Функция ДоляНакапливаемыхБаллов(СуммаПокупок)

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ШкалаБонуснойПрограммыДиапазоны.ПроцентНакопления КАК ПроцентНакопления
	|ИЗ
	|	РегистрСведений.АктуальнаяШкалаБонуснойПрограммы.СрезПоследних(&Период,) КАК
	|		АктуальнаяШкалаБонуснойПрограммыСрезПоследних
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ШкалаБонуснойПрограммы.Диапазоны КАК ШкалаБонуснойПрограммыДиапазоны
	|		ПО АктуальнаяШкалаБонуснойПрограммыСрезПоследних.Шкала = ШкалаБонуснойПрограммыДиапазоны.Ссылка
	|ГДЕ
	|	ШкалаБонуснойПрограммыДиапазоны.НижняяГраница <= &СуммаПокупок
	|	И (ШкалаБонуснойПрограммыДиапазоны.ВерхняяГраница > &СуммаПокупок
	|	ИЛИ ШкалаБонуснойПрограммыДиапазоны.ВерхняяГраница = 0)";

	Запрос.УстановитьПараметр("Период", Дата);
	Запрос.УстановитьПараметр("СуммаПокупок", СуммаПокупок);

	РезультатЗапроса = Запрос.Выполнить();

	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();

	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.ПроцентНакопления;
	КонецЦикла;

	Возврат 0;

КонецФункции

#КонецОбласти

#Область Инициализация

#КонецОбласти

#КонецЕсли