class BSON
  struct ObjectId
    include Comparable(ObjectId)

    def initialize(@handle : LibBSON::Oid*)
    end

    def initialize(str : String)
      handle = Pointer(LibBSON::Oid).malloc(1)
      LibBSON.bson_oid_init_from_string(handle, str.to_unsafe)
      initialize(handle)
    end

    def initialize
      ctx = LibBSON.bson_context_get_default
      handle = Pointer(LibBSON::Oid).malloc(1)
      LibBSON.bson_oid_init(handle, ctx)
      initialize(handle)
    end

    def self.new(pull : JSON::PullParser)
      value = BSON::ObjectId.new pull.string_value
      pull.read_next
      value
    end

    def hash
      LibBSON.bson_oid_hash(@handle)
    end

    def to_s
      buf = StaticArray(UInt8, 25).new(0_u8)
      LibBSON.bson_oid_to_string(@handle, buf)
      # bson_oid_to_string returns a null-terminated string
      String.new(buf.to_slice[0...-1])
    end

    def to_json(builder : JSON::Builder)
      builder.string self.to_s
    end

    def ==(other : ObjectId)
      LibBSON.bson_oid_equal(@handle, other)
    end

    def ==(other)
      false
    end

    def <=>(other : ObjectId)
      LibBSON.bson_oid_compare(@handle, other)
    end

    def to_unsafe
      @handle
    end

    def time
      t = LibBSON.bson_oid_get_time_t(@handle)
      ts = LibC::Timespec.new
      ts.tv_sec = t
      Time.new(ts, Time::Location::UTC)
    end
  end
end
