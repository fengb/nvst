FENGB-NVST
=====
Why rewrite
-----
I had originally implemented FENGB-NVST as a Django project:
[pynvest](https://github.com/fengb/pynvest)

When trying to add new features in late 2013, I hit numerous problems I had
never encountered in Rails:
* testing -- unittest is still fugly and pytest doesn't work out of the box
* dependencies -- **bundler** may not be **npm** but it is still better than **pip**
* querying -- QuerySet/Manager cannot hook into relations properly without
              hackery.  And why/how are they different?

Most of the reasons that I originally chose Django were fixed in Rails 3
(engines, Arel, RailsAdmin, Devise).  On top of which, I had considerably less
free time to experiment so I just ported everything to Rails.

I still prefer the Python language/community to Ruby.
