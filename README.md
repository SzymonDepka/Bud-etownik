Kod który wykonywałem znajduję się w folderze lib oraz w pliku pubsec.yaml

Link do strony na Netlify: (https://budzetownik-94f1af.netlify.app/)

# Charakterystyka oprogramowania:
Nazwa skrócona: Budżetownik

Nazwa pełna: Budżetownik- aplikacja do zarządzania budżetem osobistym i domowym

Budżetownik to aplikacja mobilna stworzona w technologii Flutter. Jej celem jest wspomaganie użytkownika w planowaniu, monitorowaniu i analizie finansów domowych i osobistych. Aplikacja umożliwia użytkownikowi rejestrowanie przychodów, kosztów zmiennych oraz kosztów stałych z podziałem na kategorie, a następnie automatyczne obliczanie salda w ujęciu dziennym miesięcznym i rocznym, oraz generowanie kołowych wykresów podsumowujących dla dowolnego okresu czasu.

# Prawa autorskie:
a)Autor- Szymon Depka (praca z użyciem modelu sztucznej inteligencji ChatGPT-5.2 do generowania „szkieletów” poszczególnych funkcjonalności aplikacji oraz do pomocy w debugowaniu)

b)Warunki licencyjne-licencja MIT

# Specyfikacja wymagań:
F-01	Dodawanie transakcji	Użytkownik może dodawać przychody oraz koszty zmienne z podaniem kwoty, kategorii i opisu.	1	Funkcjonalne / Transakcje

F-02	Edycja transakcji	Użytkownik może edytować wcześniej dodane transakcje.	2	Funkcjonalne / Transakcje

F-03	Usuwanie transakcji	Użytkownik może usunąć wybrane transakcje z listy.	1	Funkcjonalne / Transakcje

F-04	Dodawanie kosztów stałych	Użytkownik może definiować koszty stałe z określeniem kwoty, kategorii oraz okresu (miesięczny/roczny) 	1	Funkcjonalne / Koszty stałe

F-05	Edycja kosztów stałych	Użytkownik może modyfikować parametry wcześniej dodanych kosztów stałych, w taki sam sposób jak parametry transakcji.	2	Funkcjonalne / Koszty stałe

F-06	Usuwanie kosztów stałych	Użytkownik może usuwać koszty stałe z systemu w taki sam sposób jak usuwa transakcje.	1	Funkcjonalne / Koszty stałe

F-07	Kategorie kosztów i przychodów	Użytkownik może przypisywać kategorie do transakcji i kosztów stałych.	2	Funkcjonalne / Kategorie

F-08	Podsumowanie budżetu	System automatycznie oblicza przychody, koszty zmienne, koszty stałe oraz saldo.	1	Funkcjonalne / Budżet

F-09	Widoki czasowe budżetu	Użytkownik może przeglądać budżet w ujęciu dziennym, miesięcznym i rocznym.	1	Funkcjonalne / Budżet

F-10	Raport według kategorii	System generuje zestawienie kosztów według kategorii w wybranym zakresie dat.	2	Funkcjonalne / Raporty

F-11	Wykres kołowy	Dane raportu według kategorii prezentowane są w formie wykresu kołowego.	2	Funkcjonalne / Raporty

NF-01	Intuicyjny interfejs	Aplikacja posiada prosty i czytelny interfejs użytkownika.	1	Pozafunkcjonalne

NF-02	Wydajność	Operacje dodawania i odczytu danych wykonywane są bez zauważalnych opóźnień.	1	Pozafunkcjonalne

NF-03	Praca offline	Aplikacja działa bez dostępu do Internetu, dane są przechowywane lokalnie.	2	Pozafunkcjonalne

NF-04	Przenośność	Aplikacja może być uruchamiana na systemach Android i iOS.	2	Pozafunkcjonalne

NF-05	Rozszerzalność	Architektura aplikacji umożliwia łatwe dodawanie nowych funkcji w przyszłości.	3	Pozafunkcjonalne

# Architektura sytemu/oprogramowania:
a) Architektura rozwoju:

•	Flutter SDK- narzędzie do tworzenia aplikacji mobilnych

•	Dart- język programowania Fluttera

•	Visual Studio Code- środowisko programistyczne, główna przestrzeń robocza

•	Android Studio (emulator)- narzędzia do uruchamiania i testów na Androidzie

•	Git- system kontroli wersji

•	Hive- lokalna baza danych NoSQL

•	GitHub- repozytorium kodu

•	Netlify- webowa wersja aplikacji do prezentowania

 b) Architektura uruchomieniowa:
 
•	Flutter Engine- środowisko uruchomieniowe aplikacji

•	Dart Runtime- wykonywanie kodu aplikacji

•	Android- system operacyjny urządzenia docelowego

•	Hive- przechowywanie danych lokalnie

•	Material Design- warstwa interfejsu użytkownika

•	Urządzenie mobilne- uruchamianie aplikacji
# Testy:
a)Scenariusze testów:

•	Dodanie przychodu- użytkownik dodaje nową transakcję przychodu z określoną nazwą, kwotą i kategorią. Transakcja zostaje zapisana i jest widoczna na liście.

•	Dodanie kosztu zmiennego- użytkownik dodaje koszt zmienny z określoną kwotą i kategorią. Transakcja zostaje zapisana i jest widoczna na liście.

•	Dodanie kosztu stałego miesięcznego- użytkownik dodaje koszt stały miesięczny. Koszt zostaje zapisany i uwzględniony w ostatecznym budżecie

•	Dodanie kosztu stałego rocznego- użytkownik dodaje koszt stały roczny. Koszt zostaje zapisany i uwzględniony w budżecie

•	Obliczanie budżetu rocznego- na ekranie budżetu użytkownik przełącza widok na roczny. System poprawnie wyświetla, przychody, koszty stałe oraz koszty zmienne

•	Obliczanie budżetu miesięcznego- na ekranie budżetu użytkownik przełącza widok na miesięczny. System poprawnie wyświetla, przychody, koszty stałe oraz koszty zmienne

•	Raport według kategorii- użytkownik otwiera raport kategorii. Wyświetlany jest wykres kołowy z poprawnymi sumami.

•	Zmiana zakresu dat raportu- użytkownik wybiera inny zakres dat. Dane raportu są aktualizowane.

b)Sprawozdanie z wykonanania scenariuszy testów:

Testy zostały przeprowadzone manualnie w środowisku deweloperskim z wykorzystaniem emulatora systemu Android. Każdy ze zdefiniowanych scenariuszy testowych został wykonany zgodnie z opisem, a wyniki porównano z oczekiwanymi rezultatami. Wszystkie testy zakończyły się wynikiem pozytywnym, a aplikacja zachowywała się stabilnie i zgodnie ze specyfikacją. Nie stwierdzono błędów krytycznych uniemożliwiających korzystanie z aplikacji.

