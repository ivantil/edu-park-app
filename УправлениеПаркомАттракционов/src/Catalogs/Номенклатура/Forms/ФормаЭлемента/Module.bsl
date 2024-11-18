
#Область ОписаниеПеременных

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УправлениеВидимостьюЭлементовФормы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ВидНоменклатурыПриИзменении(Элемент)
	
	УправлениеВидимостьюЭлементовФормы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

// Код процедур и функций

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УправлениеВидимостьюЭлементовФормы()
	
	ЭтоПосещениеАттракциона = Объект.ВидНоменклатуры = Перечисления.ВидыНоменклатуры.ПосещениеАттракциона;
	
	Элементы.ВидАттракциона.Видимость = ЭтоПосещениеАттракциона;
	Элементы.КоличествоПосещений.Видимость = ЭтоПосещениеАттракциона;
	
КонецПроцедуры

#КонецОбласти
