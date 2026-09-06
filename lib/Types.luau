-- Types
export type PrimitiveType = string | number | boolean
export type SequenceType = NumberSequence | ColorSequence
export type VectorType = Vector3 | Vector2
export type UDimType = UDim2 | UDim
export type RobloxClass = BrickColor | Color3 | CFrame | NumberRange | Rect | Font

export type AttributeValue = PrimitiveType | SequenceType | VectorType | UDimType | RobloxClass
export type SupportedValue = AttributeValue | Instance

export type Proxy = typeof(setmetatable({}, {
    __index = function(_, key: string): any
        return
    end,
    __newindex = function(_, key: string, value: SupportedValue): any
        return
    end
}))

-- Module
local Types = {}

Types.SupportedTypes = {
	"string",
	"number",
	"boolean",
	"NumberSequence",
	"ColorSequence",
	"Vector3",
	"Vector2",
	"UDim2",
	"UDim",
	"BrickColor",
	"Color3",
	"CFrame",
	"NumberRange",
	"Rect",
	"Font",
	"Instance",
}

-- Functions
function Types.isSupportedType(value: any): boolean
	local valueType = typeof(value)

	if valueType == "table" then
		for _, child in value do
			if Types.isSupportedType(child) then
				continue
			end

			return false
		end

		return true
	end

	for _, supportedType in Types.SupportedTypes do
		if valueType ~= supportedType then
			continue
		end

		return true
	end

	return false
end

function Types.typeAssert(value: any, expectedType: string)
	local valueType = typeof(value)
	assert(valueType == expectedType, string.format("Expected %s, got %s.", expectedType, valueType))
end

function Types.typeAssertSupported(value: any)
	if typeof(value) == "table" then
		assert(Types.isSupportedType(value), "Table contains unsupported types.")
		return
	end

	assert(Types.isSupportedType(value), string.format("Unsupported type: %s", typeof(value)))
end

function Types.typeInstanceAssert(value: any, expectedClass: string)
	local valueType = typeof(value)
	assert(valueType == "Instance", string.format("Expected Instance, got %s.", valueType))
	assert(value:IsA(expectedClass), string.format("Expected %s, got %s.", expectedClass, value.ClassName))
end

-- Return
return Types
