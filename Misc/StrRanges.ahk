class StrRanges {
	_left  := 0
	_right := 0
	
	_isNumber := false
	
	__remainder := ""
	__offset    := 0
	
	__New(l, r, isNum, lLength) {
		this._left  := l
		this._right := r
		this.__offset := lLength
		this._isNumber := isNum
	}
	
	static Get(input) {
		len := StrLen(input)
		ranges := []
		
		sStart := len
		initialStr := ""
		
		totalLength := 1
		
		i := len+1
		while --i > 5 {
			ch := SubStr(input, i, 1)
			
			if ch == "]" {
				pStart := i
				pLen := 1
				
				while --i > 0 {
					ch := SubStr(input, i, 1)
					pLen++
					
					if ch == "]" {
						pStart := i
						pLen := 1
						continue
					}
					
					if ch != "[" {
						continue
					}
					
					if not p := StrRanges._New(SubStr(input, i, pLen)) {
						break
					}
					
					p._GetNext(&next)
					initialStr := next SubStr(input, i+pLen, sStart-pStart) initialStr
					
					p._Remainder := SubStr(initialStr, p._Offset+1)
					totalLength *= p._Total
					ranges.Push(p)
					
					sStart := i-1
					break
				}
			}
		}
		
		if sStart > 0 {
			initialStr := SubStr(input, 1, sStart) initialStr
		}
		
		if totalLength == 1 {
			return [initialStr]
		}
		
		variations := []
		variations.Capacity := totalLength
		variations.Push(initialStr)
		
		i := ranges.Length+1
		while --i > 0 {
			r := ranges[i]
			len := variations.Length
			
			while r._GetNext(&next) {
				j := 0
				while ++j <= len {
					prevVar := variations[j]
					var := SubStr(prevVar, 1, StrLen(prevVar)-r._Offset) next r._Remainder
					variations.Push(var)
				}
			}
		}
		
		return variations
	}
	
	static _New(p) {
		pLen := StrLen(p)
		
		if not i := InStr(p, "..") {
			return ""
		}
		
		l := SubStr(p, 2, i-2)
		r := SubStr(p, i+2, pLen-i-2)
		
		if IsNumber(l) && IsNumber(r) {
			lNum := Number(l)
			rNum := Number(r)
			
			if lNum > rNum {
				return ""
			}
			
			return StrRanges(lNum, rNum, true, StrLen(l))
		}
		
		ordL := Ord(l)
		ordR := Ord(r)
		
		if (ordL < 65 || ordL > 90 && ordL < 97 || ordL > 122)
			|| (ordR < 65 || ordR > 90 && ordR < 97 || ordR > 122) 
		{
			return ""
		}
		
		lNum := ordL - (IsLower(l) ? 96 : 38)
		rNum := ordR - (IsLower(r) ? 96 : 38)
		
		if lNum > rNum {
			return ""
		}
		
		return StrRanges(lNum, rNum, false, 1)
	}
	
	_Remainder {
		get => this.__remainder
		set {
			this.__remainder := value
			this.__offset += StrLen(value)
		}
	}
	
	_Offset => this.__offset
	
	_Total => this._isNumber ? ((this._left-1)*-1 + this._right + 1) : (this._right-this._left+2)
	
	_GetNext(&next) {
		if this._left > this._right {
			next := ""
			return false
		}
		
		next := this._isNumber ? String(this._left) : StrRanges._chars[this._left]
		this._left++
		return true
	}
	
	static _chars := [
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
	]
}