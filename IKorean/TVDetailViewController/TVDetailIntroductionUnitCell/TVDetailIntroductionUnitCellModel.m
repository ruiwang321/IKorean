//
//  TVDetailIntroductionUnitCellModel.m
//  ICinema
//
//  Created by yunlongwang on 16/7/8.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "TVDetailIntroductionUnitCellModel.h"
@interface TVDetailIntroductionUnitCellModel ()
{
    NSMutableAttributedString * m_expandButtonTitleWithExpand;
    NSMutableAttributedString * m_expandButtonTitleWithClose;
}
@property (nonatomic,assign,readwrite) CGRect grayViewFrame;
@property (nonatomic,assign,readwrite) CGRect blueImageFrame;
@property (nonatomic,assign,readwrite) CGRect titleLabelFrame;
@property (nonatomic,assign,readwrite) BOOL isCanExpand;
@property (nonatomic,assign,readwrite) CGRect expandButtonFrame;
@property (nonatomic,weak,readwrite) NSAttributedString * expandButtonTitle;
@property (nonatomic,copy,readwrite) NSAttributedString * introductionString;
@property (nonatomic,assign,readwrite) CGRect introductionLabelFrame;
@property (nonatomic,assign,readwrite) CGFloat cellHeight;

@property (nonatomic,assign)CGFloat introductionLabelNormalHeight;
@property (nonatomic,assign)CGFloat introductionLabelExpandHeight;


@end

@implementation TVDetailIntroductionUnitCellModel
-(id)initWithIntroduction:(NSString *)introduction
                cellWidth:(CGFloat)cellWidth
{
    if (self=[super init])
    {
        introduction=[introduction stringByReplacingOccurrencesOfString:@" " withString:@""];
        introduction=[introduction stringByReplacingOccurrencesOfString:@"　" withString:@""];
        introduction=[introduction stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
        NSArray * array=[introduction componentsSeparatedByString:@"\n"];
        NSMutableString * stringOfIntro=[NSMutableString stringWithString:@""];
    
        for (NSString * string in array)
        {
            if ([string length])
            {
                if ([stringOfIntro length]) {
                    [stringOfIntro appendString:@"\n"];
                }
                [stringOfIntro appendString:string];
            }
        }
        
        _grayViewFrame=CGRectMake(0, 0, cellWidth, 5);
        _blueImageFrame=CGRectMake(0,CGRectGetMaxY(_grayViewFrame)+10, 2.5, 14);
        _titleLabelFrame=CGRectMake(CGRectGetMaxX(_blueImageFrame)+7, CGRectGetMinY(_blueImageFrame), 100, 14);
        
        _introductionLabelNormalHeight=56;
        CGFloat originXOfIntro=CGRectGetMinX(_titleLabelFrame);
        CGFloat originYOfIntro=CGRectGetMaxY(_titleLabelFrame)+10;
        CGFloat maxWidthOfIntro=cellWidth-2*originXOfIntro;
        
        NSStringDrawingOptions option=NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
        
        NSMutableParagraphStyle * paragraphStyleOfIntro=[[NSMutableParagraphStyle alloc]init];
        paragraphStyleOfIntro.alignment = NSTextAlignmentJustified;
        paragraphStyleOfIntro.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphStyleOfIntro.lineSpacing=5;
        paragraphStyleOfIntro.paragraphSpacing=2;
        
        NSDictionary * dicOfIntroAttributes=@{
                                              NSFontAttributeName:[UIFont fontWithName:HYQiHei_50Pound size:13],
                                              NSForegroundColorAttributeName:[UIColor colorWithRed:151.0f/255.0f green:151.0f/255.0f blue:151.0f/255.0f alpha:1],
                                              NSParagraphStyleAttributeName:paragraphStyleOfIntro
                                              };
        
        self.introductionString=[[NSAttributedString alloc] initWithString:([[ICEAppHelper shareInstance]isStringIsEmpty:stringOfIntro]?@"暂无视频介绍":stringOfIntro)
                                                                attributes:dicOfIntroAttributes];
        
        CGSize sizeOfIntroduction=[_introductionString boundingRectWithSize:CGSizeMake(maxWidthOfIntro, 10000)
                                                                    options:option
                                                                    context:nil].size;
        
        CGFloat introTextWidth=sizeOfIntroduction.width;
        CGFloat introTextHeight=sizeOfIntroduction.height;
        
        if (introTextHeight>_introductionLabelNormalHeight)
        {
            _isCanExpand=YES;
            _introductionLabelExpandHeight=introTextHeight;
            _introductionLabelFrame=CGRectMake(originXOfIntro, originYOfIntro, introTextWidth, _introductionLabelNormalHeight);
            _expandButtonFrame=CGRectMake(cellWidth-50, CGRectGetMinY(_titleLabelFrame)-5, 50, 25);
            
            NSDictionary * dicOfExpandButtonAttributes=@{
                                                         NSFontAttributeName:[UIFont fontWithName:HYQiHei_50Pound size:12],
                                                         NSForegroundColorAttributeName:[UIColor colorWithRed:36.0f/255.0f green:175.0f/255.0f blue:255.0f/255.0f alpha:1]};
            
            m_expandButtonTitleWithExpand=[[NSMutableAttributedString alloc] init];
            
            NSAttributedString * expandTextAttrString=[[NSAttributedString alloc] initWithString:@"展开 "
                                                                                      attributes:dicOfExpandButtonAttributes];
            
            UIImage * expandImage=IMAGENAME(@"expandBlue@2x", @"png");
            NSTextAttachment * textAttachmentOfExpandImage = [[NSTextAttachment alloc] init];
            textAttachmentOfExpandImage.image = expandImage;
            textAttachmentOfExpandImage.bounds = CGRectMake(0, 2, expandImage.size.width, expandImage.size.height);
            
            NSAttributedString * expandImageAttrString=[[NSAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachmentOfExpandImage]];
            [m_expandButtonTitleWithExpand appendAttributedString:expandTextAttrString];
            [m_expandButtonTitleWithExpand appendAttributedString:expandImageAttrString];
            
            m_expandButtonTitleWithClose=[[NSMutableAttributedString alloc] init];
            
            NSAttributedString * closeTextAttrString=[[NSAttributedString alloc] initWithString:@"收起 "
                                                                                     attributes:dicOfExpandButtonAttributes];
            
            UIImage * closeImage=IMAGENAME(@"closeBlue@2x", @"png");
            NSTextAttachment * textAttachmentOfCloseImage = [[NSTextAttachment alloc] init];
            textAttachmentOfCloseImage.image = closeImage;
            textAttachmentOfCloseImage.bounds = CGRectMake(0, 2, expandImage.size.width, expandImage.size.height);
            
            NSAttributedString * closeImageAttrString=[[NSAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachmentOfCloseImage]];
            [m_expandButtonTitleWithClose appendAttributedString:closeTextAttrString];
            [m_expandButtonTitleWithClose appendAttributedString:closeImageAttrString];
            
            self.expandButtonTitle=m_expandButtonTitleWithExpand;
        }
        else
        {
            _introductionLabelNormalHeight=introTextHeight;
            _introductionLabelFrame=CGRectMake(originXOfIntro, originYOfIntro, introTextWidth, _introductionLabelNormalHeight);
        }
        _cellHeight=CGRectGetMaxY(_introductionLabelFrame)+10;
    }
    return self;
}

-(void)setIsExpand:(BOOL)isExpand
{
    if (_isCanExpand)
    {
        _isExpand=isExpand;
        if (_isExpand)
        {
            _expandButtonTitle=m_expandButtonTitleWithClose;
            CGRect frameOfIntroFrame=_introductionLabelFrame;
            frameOfIntroFrame.size.height=_introductionLabelExpandHeight;
            _introductionLabelFrame=frameOfIntroFrame;
            
            _cellHeight+=(_introductionLabelExpandHeight-_introductionLabelNormalHeight) ;
        }
        else
        {
            _expandButtonTitle=m_expandButtonTitleWithExpand;
            CGRect frameOfIntroFrame=_introductionLabelFrame;
            frameOfIntroFrame.size.height=_introductionLabelNormalHeight;
            _introductionLabelFrame=frameOfIntroFrame;
            
            _cellHeight-=(_introductionLabelExpandHeight-_introductionLabelNormalHeight);
        }
    }
}

@end
