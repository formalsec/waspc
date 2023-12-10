(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (func (result i32)))
  (type (;2;) (func (param i32)))
  (type (;3;) (func))
  (type (;4;) (func (param i32) (result i32)))
  (import "summaries" "alloc" (func $__owi_alloc (type 0)))
  (import "symbolic" "i32_symbol" (func $__i32 (type 1)))
  (import "symbolic" "assume" (func $__owi_assume (type 2)))
  (func $__original_main (type 1) (result i32)
    (local i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee 0
    global.set $__stack_pointer
    local.get 0
    i32.const 0
    i32.store offset=12
    local.get 0
    call $owi_i32
    i32.store offset=8
    local.get 0
    i32.load offset=8
    i32.const 2
    i32.gt_s
    i32.const 1
    i32.and
    call $owi_assume
    local.get 0
    i32.load offset=8
    i32.const 16
    i32.lt_s
    i32.const 1
    i32.and
    call $owi_assume
    local.get 0
    i32.const 32
    call $malloc
    i32.store offset=4
    local.get 0
    i32.const 0
    i32.store
    block  ;; label = @1
      loop  ;; label = @2
        local.get 0
        i32.load
        local.get 0
        i32.load offset=8
        i32.lt_s
        i32.const 1
        i32.and
        i32.eqz
        br_if 1 (;@1;)
        local.get 0
        i32.load offset=4
        local.get 0
        i32.load
        i32.const 2
        i32.shl
        i32.add
        i32.const 0
        i32.store
        local.get 0
        local.get 0
        i32.load
        i32.const 1
        i32.add
        i32.store
        br 0 (;@2;)
      end
    end
    local.get 0
    i32.const 16
    i32.add
    global.set $__stack_pointer
    i32.const 0)
  (func $owi_malloc (type 0) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    call $__owi_alloc)
  (func $owi_i32 (type 1) (result i32)
    call $__i32)
  (func $owi_assume (type 2) (param i32)
    local.get 0
    call $__owi_assume)
  (func $_start (type 3)
    call $__original_main
    drop)
  (func $malloc (type 4) (param i32) (result i32)
    (local i32)
    i32.const 0
    i32.const 0
    i32.load offset=1024
    local.tee 1
    local.get 0
    i32.add
    i32.store offset=1024
    local.get 1
    local.get 0
    call $owi_malloc)
  (table (;0;) 1 1 funcref)
  (memory (;0;) 129)
  (global $__stack_pointer (mut i32) (i32.const 8389648))
  (export "memory" (memory 0))
  (export "_start" (func $_start))
  (data $.data (i32.const 1024) "\10\04\80\00"))
