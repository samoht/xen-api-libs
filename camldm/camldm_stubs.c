#include <libdevmapper.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

/* map is an array of 4-tuples 
 * (start : int64, size : int64, type : string, params : string)
 * format of params depends upon the type
 */
void camldm_create(value name, value map) 
{
  CAMLparam2(name,map);

  struct dm_task *dmt;
  int i;
  uint64_t start, size;
  char *ty,*params;

  if(!(dmt = dm_task_create(DM_DEVICE_CREATE)))
    caml_failwith("Failed to create task!");

  if(!dm_task_set_name(dmt, String_val(name))) 
    goto out;

  for(i=0; i<Wosize_val(map); i++) {
    start=Int64_val(Field(Field(map,i),0));
    size=Int64_val(Field(Field(map,i),1));
    ty=String_val(Field(Field(map,i),2));
    params=String_val(Field(Field(map,i),3));

    printf("%" PRIu64 " %" PRIu64 " %s %s\n", start, size, ty, params);

    if(!dm_task_add_target(dmt, start, size, ty, params))
      goto out;
  }
  
  if(!dm_task_run(dmt))
    goto out;

  goto win;

 out:
  dm_task_destroy(dmt);
  caml_failwith("Failed!");

 win:
  CAMLreturn0;  
}


void camldm_mknods(value dev)
{
  CAMLparam1 (dev);

  if(caml_string_length(dev)==0) {
    dm_mknodes(NULL);
  } else {
    dm_mknodes(String_val(dev));
  }
  
  CAMLreturn0;
}

value camldm_table(value dev)
{
  CAMLparam1 (dev);
  CAMLlocal4 (result,r,tuple,tmp);

  struct dm_task *dmt;
  struct dm_info info;

  void *next = NULL;
  uint64_t start, length;
  char *target_type = NULL;
  char *params = NULL;

  if(!(dmt = dm_task_create(DM_DEVICE_TABLE)))
    caml_failwith("Could not create dm_task");

  if(!dm_task_set_name(dmt, String_val(dev))) {
    dm_task_destroy(dmt);
    caml_failwith("Could not set device");
  }

  if(!dm_task_run(dmt)) {
    dm_task_destroy(dmt);
    caml_failwith("Failed to run task");
  }

  if (!dm_task_get_info(dmt, &info) || !info.exists) {
    dm_task_destroy(dmt);
    caml_failwith("Failed to get info");
  }

  result=caml_alloc_tuple(10);

  Store_field(result,0,Val_bool(info.exists));
  Store_field(result,1,Val_bool(info.suspended));
  Store_field(result,2,Val_bool(info.live_table));
  Store_field(result,3,Val_bool(info.inactive_table));
  Store_field(result,4,caml_copy_int32(info.open_count));
  Store_field(result,5,caml_copy_int32(info.event_nr));
  Store_field(result,6,caml_copy_int32(info.major));
  Store_field(result,7,caml_copy_int32(info.minor));
  Store_field(result,8,Val_bool(info.read_only));

  tmp=Val_int(0);

  do { 
    next = dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
    dm_task_get_info(dmt, &info);

    tuple=caml_alloc_tuple(4);
    Store_field(tuple,0,caml_copy_int64(start));
    Store_field(tuple,1,caml_copy_int64(length));
    Store_field(tuple,2,caml_copy_string(target_type));
    Store_field(tuple,3,caml_copy_string(params));

    r=caml_alloc(2,0);
    Store_field(r, 0, tuple);
    Store_field(r, 1, tmp);

    tmp=r;

    printf("params=%s\n",params);
  } while(next);

  Store_field(result,9,tmp);

  CAMLreturn(result);
}

void _simple(int task, const char *name) 
{
  struct dm_task *dmt;

  if (!(dmt = dm_task_create(task)))
    caml_failwith("Failed to create task");

  if(!dm_task_set_name(dmt, name)) {
    dm_task_destroy(dmt);
    caml_failwith("Could not set device");
  }
  
  if(!dm_task_run(dmt)) {
    dm_task_destroy(dmt);
    caml_failwith("Failed to run task");
  }

  dm_task_destroy(dmt);
}

void camldm_remove(value device)
{
  CAMLparam1(device);
  _simple(DM_DEVICE_REMOVE,String_val(device));
  CAMLreturn0;
}

void camldm_mknod(value path, value mode, value major, value minor)
{
  CAMLparam4(path, mode, major, minor);
  mknod(String_val(path),S_IFBLK | Int_val(mode), makedev(Int_val(major),Int_val(minor)));
  CAMLreturn0;
}