//
//  SystemUtil.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <objc/objc-runtime.h>
#import "SystemUtil.h"
#import "ClassHolder.h"

@interface SystemUtil(private)
+ (Class*) getAllClasses: (int*) count;
@end

@implementation SystemUtil

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ (Class*) getAllClasses: (int*) count
{
  (*count) = objc_getClassList(NULL, 0);
  Class *classes = malloc((*count) * sizeof(Class));
  if (classes)
  {
    int newCount = objc_getClassList(classes, (*count));
    while ((*count) < newCount)
    {
      (*count) = newCount;
      free(classes);
      classes = malloc((*count) * sizeof(Class));
      if (classes)
        newCount = objc_getClassList(classes, (*count));
    }
    (*count) = newCount;
  }
  return classes;
}

+ (NSArray*) getClassesConformingToProcol: (Protocol*) protocol
{
  int *count = malloc(sizeof(int));
  Class *classes = [SystemUtil getAllClasses: count];
  NSMutableArray *classHolders = [NSMutableArray array];

  for(int i = 0; i < (*count); i++)
  {
    Class clazz = classes[i];
    if(class_conformsToProtocol(clazz, protocol))
    {
      ClassHolder *holder = [[ClassHolder alloc] initWithClass: clazz];
      [classHolders addObject:holder];
    }
  }
  return classHolders;
}

+ (NSArray*) getAllRegisteredClasses
{
  int *count = malloc(sizeof(int));
  Class *classes = [SystemUtil getAllClasses: count];
  NSMutableArray *classHolders = [NSMutableArray array];
  
  for(int i = 0; i < (*count); i++)
  {
    Class clazz = classes[i];
    ClassHolder *holder = [[ClassHolder alloc] initWithClass: clazz];
    [classHolders addObject:holder];
  }
  
  return classHolders;
}

@end
