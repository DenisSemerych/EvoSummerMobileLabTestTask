# EvoSummerMobileLabTestTask
**Задание - сделать приложение с заметками исходя из требований**

## Сторонние библиотеки, которые были использованы
**RealmSwift для работы с базой данных**<br />
*Кроме этой билиотеки - только UIKit исходя из того, что ничего другого не было указано в тестовом задании*
### Реализовано

**Две части задания, кроме пагинации, которая, в связи с деталями функционирования Realm
и исходя из задания, была не сильно необходима, детальнее об этом здесь: [Realm Documentation](https://realm.io/docs/swift/latest/#limiting-results)**
<br />**Особенности реализации**<br />
*Исходя из задания редактирование на экране заметок включается с помощью кнопки и не доступно по нажатию<br />
Клавиатура в textView NoteDetailViewController отключается от тапа между самой клавиатурой и textView<br />
При нажатии на кнопку "Назад" изменения в заметке сохраняются при необходимости, однако закоментив отмеченую линию в<br />
viewWillDisapear NoteDetailViewController можно это поведение убрать и выключить сохранение при возврате на предыдущий контроллер*
<br />**Что хотелось бы добавить**<br />
*Из того, с чем ознакомился за период работы над данным приложением - паттерн Navigation Coordinators.<br />
К сожалению, узнал о нем чуть позже, чем нужно было для нормальной реализации его в отправляемом приложении.
Хотелось бы переделать все в соответсвии с ним.*
