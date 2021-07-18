#include <iomanip>
#include <iostream>

// https://stackoverflow.com/questions/44838810/c-string-formatting-like-python-format

class format_guard {
  std::ostream& _os;
  std::ios::fmtflags _f;

public:
  format_guard(std::ostream& os = std::cout) : _os(os), _f(os.flags()) {}
  ~format_guard() { _os.flags(_f); }
};

template <typename T>
struct table_entry {
  const T& entry;
  int width;
  table_entry(const T& entry_, int width_)
      : entry(entry_), width(static_cast<int>(width_)) {}
};

template <typename T>
std::ostream& operator<<(std::ostream& os, const table_entry<T>& e) {
  format_guard fg(os);
  return os << std::setw(e.width) << std::right << e.entry; 
}

//~ And then you would use it as std::cout << table_entry("some_string", 10). You can adapt table_entry to your needs.
//~ If you don't have class template argument deduction you could implement a make_table_entry function for template type deduction.
//~ The format_guard is needed since some formatting options on std::ostream are sticky.
