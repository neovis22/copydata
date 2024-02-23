/*
    Library: ason
    Author: neovis
    
    json보다 빠른 처리속도를 목적으로 구현된 비표준 라이브러리
*/

class ason {
    
    load(path, encoding="utf-8") {
        try
            return this.parse(FileOpen(path, "r", encoding).read())
        catch err
            throw err
    }
    
    dump(path, obj, encoding="utf-8") {
        try
            return FileOpen(path, "w", encoding).write(this.stringify(obj))
        catch err
            throw err
    }
    
    parse(byref src) {
        stack := [], obj := [], depth := pos := 0
        while ((ch := SubStr(src, ++ pos, 1)) != "")
            switch (ch) {
                case "!": RegExMatch(src, "\G[^:{]*", m, pos+1)
                    , key := this.unescape(m), pos += StrLen(m)
                case ":": RegExMatch(src, "\G[^!}]*", m, pos+1)
                    , obj[key] := this.unescape(m), pos += StrLen(m)
                case "{": stack[++ depth] := value := [], obj[key] := value, obj := value
                case "}": obj := stack[-- depth]
                default: throw Exception("SyntaxError: '" ch "' at position " pos)
            }
        return stack[1]
    }
    
    stringify(obj) {
        return this._stringify(obj, [])
    }
    _stringify(obj, ref) {
        if (IsObject(obj)) {
            if (ComObjValue(obj) != "")
                return ":" this.escape("{ComObject:" ComObjType(obj, "Class") "}")
            if ((ref[&obj] := ref[&obj] ? ref[&obj]+1 : 1) > 200)
                throw Exception("too much recursion")
            for i, v in obj
                res .= "!" this.escape(i) this._stringify(v, ref)
            return "{" res "}"
        }
        return ":" this.escape(obj)
    }
    
    escape(byref str) {
        return,
        (join ltrim
            StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(str,
            "\", "\1"), "{", "\2"), "}", "\3"), "!", "\4"), ":", "\5")
        )
    }
    
    unescape(byref str) {
        return,
        (join ltrim
            StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(str,
            "\5", ":"), "\4", "!"), "\3", "}"), "\2", "{"), "\1", "\")
        )
    }
}
