//
//  AliyunEffectModelTransManager.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectModelTransManager.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunEffectInfo.h"
#import "AliyunEffectMvGroup.h"
#import "AliyunEffectPasterGroup.h"
#import "AliyunEffectFilterInfo.h"
#import "AliyunEffectMusicInfo.h"
#import "AliyunEffectFontInfo.h"
#import <objc/runtime.h>


@implementation AliyunEffectModelTransManager

static AliyunEffectModelTransManager *manager = nil;
+ (AliyunEffectModelTransManager *)manager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AliyunEffectModelTransManager alloc] init];
    });
    return manager;
}


- (AliyunEffectInfo *)transEffectInfoModelWithResourceModel:(AliyunEffectResourceModel *)resourceModel {
    
    if (!resourceModel) {
        return nil;
    }
    
    NSDictionary *resourceDic = [self dictionaryWithModel:resourceModel];
    
    switch (resourceModel.effectType) {
        case 1:
            return [self effectFontWithResourceDic:resourceDic];
            break;
        case 2:
            return [self effectPasterWithResourceDic:resourceDic];
            break;
        case 3:
            return [self effectMvWithResourceDic:resourceDic];
            break;
        case 4:
        case 7:
        case 8:
            return [self effectFilterWithResourceDic:resourceDic];
            break;
        case 10:
            return [self effectFilterWithResourceDic:resourceDic];
            break;
        case 5:
            return [self effectMusicWithResourceDic:resourceDic];
            break;
        case 6:
            return [self effectPasterWithResourceDic:resourceDic];
            break;
        default:
            return [[AliyunEffectInfo alloc] init];
            break;
    }
    
}

- (AliyunEffectResourceModel *)transResourceModelWithEffectInfo:(AliyunEffectInfo *)info {
    
    NSDictionary *infoDic = [self dictionaryWithModel:info];
    AliyunEffectResourceModel *model = [[AliyunEffectResourceModel alloc] initWithDictionary:infoDic error:nil];
    [model setValue:[infoDic objectForKey:@"pasterList"] forKey:@"pasterList"];
    [model setValue:[infoDic objectForKey:@"mvList"] forKey:@"mvList"];
    
    return model;
}

#pragma mark - AliyunEffectResourceModel???AliyunEffectInfo
- (AliyunEffectFontInfo *)effectFontWithResourceDic:(NSDictionary *)resourceDic {
    
    AliyunEffectFontInfo *fontModel = [[AliyunEffectFontInfo alloc] initWithDictionary:resourceDic error:nil];
    return fontModel;
}


- (AliyunEffectPasterGroup *)effectPasterWithResourceDic:(NSDictionary *)resourceDic {
    NSError *error;
    AliyunEffectPasterGroup *pasterModel = [[AliyunEffectPasterGroup alloc] initWithDictionary:resourceDic error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    [pasterModel setValue:[resourceDic objectForKey:@"pasterList"] forKey:@"pasterList"];
    return pasterModel;
}


- (AliyunEffectMvGroup *)effectMvWithResourceDic:(NSDictionary *)resourceDic {
    
    AliyunEffectMvGroup *mvModel = [[AliyunEffectMvGroup alloc] initWithDictionary:resourceDic error:nil];
    [mvModel setValue:[resourceDic objectForKey:@"mvList"] forKey:@"mvList"];
    return mvModel;
}


- (AliyunEffectFilterInfo *)effectFilterWithResourceDic:(NSDictionary *)resourceDic {
    
    AliyunEffectFilterInfo *filterModel = [[AliyunEffectFilterInfo alloc] initWithDictionary:resourceDic error:nil];
    return filterModel;
}



- (AliyunEffectMusicInfo *)effectMusicWithResourceDic:(NSDictionary *)resourceDic {
    
    AliyunEffectMusicInfo *musicModel = [[AliyunEffectMusicInfo alloc] initWithDictionary:resourceDic error:nil];
    return musicModel;
}


#pragma mark - Model???Dictionary
- (NSDictionary *)dictionaryWithModel:(id)model {
    if (model == nil) {
        return nil;
    }
    // TODO:??????????????????musicInfoModel?????????????????????
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // ????????????/???????????????????????????
    NSString *className = NSStringFromClass([model class]);
    id classObject = objc_getClass([className UTF8String]);
    
    // ??????????????????
    UInt32 count = 0;
    objc_property_t *properties = class_copyPropertyList(classObject, &count);
    
    // ??????????????????
    for (int i = 0; i < count; i++) {
        // ????????????
        objc_property_t property = properties[i];
        // ???????????????
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property)
                                                          encoding:NSUTF8StringEncoding];
        // ???????????????
        id propertyValue = nil;
        id valueObject = [model valueForKey:propertyName];
        
        if (valueObject == nil) {
            // ???????????????????????????????????????nil????????????????????????nil????????????????????????NSNull??????
            propertyValue = [NSNull null];
        } else if ([valueObject isKindOfClass:[NSDictionary class]]) {
            propertyValue = [NSDictionary dictionaryWithDictionary:valueObject];
        } else if ([valueObject isKindOfClass:[NSArray class]]) {
            propertyValue = [NSArray arrayWithArray:valueObject];
        }  else{
            propertyValue = [NSString stringWithFormat:@"%@", [model valueForKey:propertyName]];
        }
        [dict setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    
    return [dict copy];
}

@end
