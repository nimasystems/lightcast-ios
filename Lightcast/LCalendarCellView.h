//
//  LCalendarCellView.h
//  Lightcast
//
//  Created by Martin Kovachev on 7/18/13.
//  Copyright (c) 2013 Nimasystems Ltd. All rights reserved.
//

@class LCalendarCellView;

@protocol LCalendarCellViewDelegate <NSObject>

@optional

- (void)calendarCellView:(LCalendarCellView*)calendarCellView selectedDate:(NSDate *)selectedDate;

@end

extern CGFloat const kCXCalendarCellViewLabelHeight;

@interface LCalendarCellView : UIView

@property (nonatomic, assign) id<LCalendarCellViewDelegate> delegate;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) NSInteger cellIndex;

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign) BOOL isToday;
@property (nonatomic, assign) BOOL isDateWithinCurrentMonth;

@property (nonatomic, readonly) UILabel *dateLabel;

@property (nonatomic, assign) BOOL allowsSelection;
@property (nonatomic, assign) BOOL allowsSelectionIfOtherMonth;

@property (nonatomic, strong) UIColor *defaultBgColor;
@property (nonatomic, strong) UIColor *defaultLabelTextColor;
@property (nonatomic, strong) UIColor *selectedLabelTextColor;
@property (nonatomic, strong) UIColor *selectedBgColor;
@property (nonatomic, strong) UIColor *todayBgColor;
@property (nonatomic, strong) UIColor *todayLabelTextColor;
@property (nonatomic, strong) UIColor *otherMonthBgColor;
@property (nonatomic, strong) UIColor *otherMonthLabelTextColor;
@property (nonatomic, assign) CGFloat otherMonthAlphaValue;

@property (nonatomic, assign) BOOL showsTouchEffect;

@end
