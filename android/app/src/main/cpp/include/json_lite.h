#pragma once
#include <map>
#include <memory>
#include <string>
#include <vector>

namespace kj {
    enum class Type { Null, Bool, Num, Str, Arr, Obj };

    struct Value;
    using ValuePtr = std::shared_ptr<Value>;

    struct Value {
        Type type = Type::Null;
        bool b = false;
        double num = 0;
        std::string str;
        std::vector<ValuePtr> arr;
        std::map<std::string, ValuePtr> obj;

        const ValuePtr& get(const std::string& k) const;
        std::string as_string(const std::string& k) const;
        bool as_bool(const std::string& k) const;
    };

    ValuePtr parse(const std::string& text);
    const std::vector<ValuePtr>& as_list(const ValuePtr& root);
}