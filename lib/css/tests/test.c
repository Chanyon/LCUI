#include <ctest.h>
#include <yutil.h>
#include "test.h"

int main()
{
	logger_set_level(LOGGER_LEVEL_ALL);
	ctest_describe("test_css_keywords", test_css_keywords);
	ctest_describe("test_css_value", test_css_value);
	ctest_describe("test_css_computed", test_css_computed);
	return ctest_finish();
}
