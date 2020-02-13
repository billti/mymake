#include "common.h"
#include "utils.h"

int add(int a, int b) {
  std::vector<int> vec;
  vec.push_back(a);
  vec.push_back(b);

  int result = 0;
  for(const auto& elem: vec) {
    result += elem;
  }
  return result;
}
